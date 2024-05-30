import Foundation

//**************************************************************************************************
//	MARK: HyperIDAPIAuth
//--------------------------------------------------------------------------------------------------
public class HyperIDAPIAuth : HyperIDAPIBase {
	private let	clientInfo				: ClientInfo
	
	public var	accessToken				: String?
	public var	refreshToken			: String?
	public var	isAuthorized			: Bool {
		guard let refreshToken = refreshToken else {
			return false
		}
		let jwtParts					= refreshToken.split(separator: ".")
		let base64URLEncodedPayload		= String(jwtParts[1])
		let data						= base64URLToData(base64URLEncodedPayload)!
		guard let jwtPayload = try? JSONSerialization.jsonObject(with: data),
			  let dictionary = jwtPayload as? [String : Any],
			  let exp = dictionary["exp"] as? Double,
			  Date(timeIntervalSince1970: exp).timeIntervalSinceNow > 0 else {
			return false
		}
		return true
	}

	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	public init(clientInfo			: ClientInfo,
				refreshToken		: String?				= nil,
				providerInfo		: ProviderInfo?			= ProviderInfo.production,
				openIDConfiguration	: OpenIDConfiguration?	= nil,
				urlSession			: URLSession! = URLSession.shared) async throws {
		self.clientInfo				= clientInfo
		self.refreshToken			= refreshToken
		try await super.init(providerInfo: providerInfo, openIDConfiguration: openIDConfiguration, urlSession: urlSession)
	}
	//==================================================================================================
	//	startSignInWeb2()
	//--------------------------------------------------------------------------------------------------
	public func startSignInWeb2(kycVerificationLevel:	KYCVerificationLevel? = nil) throws -> URL {
		return try authorizationStart(flowMode: .signInWeb2)
	}
	//==================================================================================================
	//	startSignInWeb3()
	//--------------------------------------------------------------------------------------------------
	public func startSignInWeb3(walletFamily:			WalletFamily? = .ethereum,
								kycVerificationLevel:	KYCVerificationLevel? = nil) throws -> URL {
		return try authorizationStart(flowMode:		.signInWeb3,
									  walletFamily:	walletFamily)
	}
	//==================================================================================================
	//	startSignInUsingWallet
	//--------------------------------------------------------------------------------------------------
	public func startSignInUsingWallet(walletGetMode	: WalletGetMode = .walletGetFast,
									   walletFamily		: WalletFamily? = .ethereum) throws -> URL {
		return try authorizationStart(flowMode:			.signInWalletGet,
									  walletGetMode:	walletGetMode,
									  walletFamily: 	walletFamily)
	}
	//==================================================================================================
	//	startSignInGuestUpgrade
	//--------------------------------------------------------------------------------------------------
	public func startSignInGuestUpgrade() throws -> URL {
		return try authorizationStart(flowMode: .signInGuestUpgrade)
	}
	//==================================================================================================
	//	startSignInIdentityProvider
	//--------------------------------------------------------------------------------------------------
	public func startSignInIdentityProvider(identityProvider		: IdentityProvider,
											kycVerificationLevel	: KYCVerificationLevel? = nil) throws -> URL {
		return try authorizationStart(flowMode:			.signInIdentityProvider,
									  identityProvider:	identityProvider)
	}
	//==================================================================================================
	//	exchangeToTokens(redirectURL : URL)
	//--------------------------------------------------------------------------------------------------
	public func exchangeToTokens(redirectURL : URL) async throws {
		let urlComponents = URLComponents(url: redirectURL, resolvingAgainstBaseURL: false)!
		guard let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value else {
			let errorDescription = urlComponents.queryItems?.first(where: { $0.name == "error_description" })?.value
			throw HyperIDAPIAuthError.authorizationInvalidRedirectURLError(description: errorDescription ?? "Unknown error")
		}
		var request = URLRequest(url: openIDConfiguration.tokenEndpoint!)
		request.httpMethod	= "POST"
		request.httpBody	= try! "grant_type=authorization_code&code=\(code)&\(clientInfo.authorizationParameters(issuer: openIDConfiguration.issuer))".data(using: .utf8)
		do {
			let (data, response) = try await urlSession.data(for: request)
			try exchangeResultProcess(httpResponse:	response as? HTTPURLResponse, data: data)
		} catch let error as HyperIDAPIBaseError { throw error }
		catch let error as HyperIDAPIAuthError { throw error }
		catch {
			throw HyperIDAPIBaseError.networkingError(description: String(describing: error))
		}
	}
	//==================================================================================================
	//	refreshAccessToken
	//--------------------------------------------------------------------------------------------------
	public func refreshTokens() async throws {
		guard let refreshToken = refreshToken else {
			throw HyperIDAPIAuthError.tokenExchangeInvalidGrant(description: "no refresh token for credentials refresh")
		}
		var request = URLRequest(url: openIDConfiguration.tokenEndpoint!)
		request.httpMethod	= "POST"
		request.httpBody	= try! "grant_type=refresh_token&refresh_token=\(refreshToken)&\(clientInfo.authorizationParameters(issuer: openIDConfiguration.issuer))".data(using: .utf8)
		do {
			let (data, response) = try await urlSession.data(for: request)
			try exchangeResultProcess(httpResponse: response as? HTTPURLResponse, data: data)
		} catch let error as HyperIDAPIBaseError { throw error }
		catch let error as HyperIDAPIAuthError { throw error }
		catch {
			throw HyperIDAPIBaseError.networkingError(description: String(describing: error))
		}
	}
	//==================================================================================================
	//	logout
	//--------------------------------------------------------------------------------------------------
	public func logout() async throws {
		guard isAuthorized else {
			accessToken = nil
			refreshToken = nil
			return
		}
		var request = URLRequest(url: openIDConfiguration.endSessionEndpoint)
		request.httpMethod	= "POST"
		request.httpBody	= try! "refresh_token=\(refreshToken!)&\(clientInfo.authorizationParameters(issuer: openIDConfiguration.issuer))".data(using: .utf8)
		do {
			let (_, response) = try await urlSession.data(for: request)
			guard let httpResponse = response as? HTTPURLResponse else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			switch httpResponse.statusCode {
			case 200..<300:
				accessToken = nil
				refreshToken = nil
			default:
				throw HyperIDAPIBaseError.serverMaintenance
			}
		} catch let error as HyperIDAPIBaseError { throw error }
		catch let error as HyperIDAPIAuthError { throw error }
		catch {
			throw HyperIDAPIBaseError.networkingError(description: String(describing: error))
		}
	}
	//==================================================================================================
	//	getUserInfo
	//--------------------------------------------------------------------------------------------------
	public func getUserInfo() async throws -> UserInfo {
		guard let accessToken = accessToken else {
			throw HyperIDAPIBaseError.invalidAccessToken
		}
		do {
			let jwtParts					= accessToken.split(separator: ".")
			let base64URLEncodedPayload		= String(jwtParts[1])
			let data						= base64URLToData(base64URLEncodedPayload)!
			return try JSONDecoder().decode(UserInfo.self, from: data)
		} catch {
			throw HyperIDAPIBaseError.invalidAccessToken
		}
	}
}

//**************************************************************************************************
//	MARK: HyperIDAPIAuth - private
//--------------------------------------------------------------------------------------------------
extension HyperIDAPIAuth {
	//**************************************************************************************************
	//	HyperIDAPIAuth.AuthorizationFlowMode
	//--------------------------------------------------------------------------------------------------
	enum AuthorizationFlowMode : String{
		case signInWeb2				= "0"
		case signInWeb3				= "3"
		case signInWalletGet		= "4"
		case signInGuestUpgrade		= "6"
		case signInIdentityProvider	= "9"
	}
	//==================================================================================================
	//	authorizationStart
	//--------------------------------------------------------------------------------------------------
	private func authorizationStart(flowMode				: AuthorizationFlowMode,
									walletGetMode			: WalletGetMode?			= nil,
									walletFamily			: WalletFamily?				= nil,
									identityProvider		: IdentityProvider?			= nil,
									KYCVerificationLevel	: KYCVerificationLevel?		= nil) throws -> URL {
		if let identityProvider = identityProvider,
		   !openIDConfiguration.identityProviders.contains(where: { $0 == identityProvider }) {
			throw HyperIDAPIAuthError.unknownIdentityProvider(provider: identityProvider.name)
		}
		if let walletFamily = walletFamily,
		   !openIDConfiguration.walletFamilies.contains(where: { walletFamily.id == $0.id}) {
			throw HyperIDAPIAuthError.unknownWalletFamily
		}
		switch KYCVerificationLevel {
		case .unsupported(code: _):
			throw HyperIDAPIBaseError.invalidKYCVerificationLevel
		default:
			break;
		}
		var urlComponents = URLComponents(url: openIDConfiguration.authEndpoint, resolvingAgainstBaseURL: false)!
		var urlQueryItems = [
			URLQueryItem(name: "response_type", value: "code"),
			URLQueryItem(name: "scope",			value: openIDConfiguration.scopes.joined(separator: " ")),
			URLQueryItem(name: "client_id",		value: clientInfo.clientId),
			URLQueryItem(name: "redirect_uri",	value: clientInfo.redirectURL),
			URLQueryItem(name: "flow_mode",		value: flowMode.rawValue)
		]
		if let walletGetMode = walletGetMode {
			urlQueryItems.append(contentsOf: [
				URLQueryItem(name: "wallet_get_mode",			value: walletGetMode.rawValue)
			])
		}
		if let walletFamily = walletFamily {
			urlQueryItems.append(contentsOf: [
				URLQueryItem(name: "wallet_family",				value: String(walletFamily.id))
			])
		}
		if let identityProvider = identityProvider {
			urlQueryItems.append(contentsOf: [
				URLQueryItem(name: "identity_provider",			value: identityProvider.name)
			])
		}
		if let kycVerificationLevel = KYCVerificationLevel {
			urlQueryItems.append(contentsOf: [
				URLQueryItem(name: "verification_level",		value: String(kycVerificationLevel.rawValue))
			])
		}
		urlComponents.queryItems = urlQueryItems
		return urlComponents.url!
	}
	//==================================================================================================
	//	exchangeResultProcess
	//--------------------------------------------------------------------------------------------------
	private func exchangeResultProcess(httpResponse	: HTTPURLResponse?,
									   data			: Data?) throws {
		guard let httpResponse = httpResponse else {
			throw HyperIDAPIBaseError.serverMaintenance
		}
		switch httpResponse.statusCode {
		case 200..<300:
			guard let tokenInfo = try? JSONDecoder().decode(TokenExchangeResponse.self, from: data!) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			accessToken		= tokenInfo.accessToken
			refreshToken	= tokenInfo.refreshToken
		case 400..<500:
			accessToken		= nil
			refreshToken	= nil
			guard let data = data else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			let errorDictionary	= try JSONSerialization.jsonObject(with: data) as? [String : Any]
			guard let errorDictionary = errorDictionary else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			switch errorDictionary["error"] as? String {
			case "invalid_request":
				throw HyperIDAPIBaseError.serverMaintenance
			case "invalid_grant":
				throw HyperIDAPIAuthError.tokenExchangeInvalidGrant(description: String(data: data, encoding: .utf8) ?? "")
			case "invalid_client":
				throw HyperIDAPIAuthError.invalidClientInfo(description: String(data: data, encoding: .utf8) ?? "")
			case "unauthorized_client":
				throw HyperIDAPIAuthError.invalidClientInfo(description: String(data: data, encoding: .utf8) ?? "")
			case "unsupported_grant_type":
				throw HyperIDAPIAuthError.invalidClientInfo(description: String(data: data, encoding: .utf8) ?? "")
			default:
				throw HyperIDAPIBaseError.serverMaintenance
			}
		default:
			accessToken		= nil
			refreshToken	= nil
			throw HyperIDAPIBaseError.serverMaintenance
		}
	}
	//==================================================================================================
	//	base64URLToData
	//--------------------------------------------------------------------------------------------------
	private func base64URLToData(_ base64URLString: String) -> Data? {
		var base64 = base64URLString
			.replacingOccurrences(of: "-", with: "+")
			.replacingOccurrences(of: "_", with: "/")
		let paddingLength = 4 - (base64.count % 4)
		if paddingLength < 4 {
			base64 += String(repeating: "=", count: paddingLength)
		}
		return Data(base64Encoded: base64)
	}
}
