import Foundation

//**************************************************************************************************
//	MARK: OpenIDConfiguration
//--------------------------------------------------------------------------------------------------
public class OpenIDConfiguration : Codable {
	public let		authEndpoint			: URL!
	public let		tokenEndpoint			: URL!
	public let		introspectionEndpoint	: URL!
	public let		userInfoEndpoint		: URL!
	public let		revokeEndpoint			: URL!
	public let		endSessionEndpoint		: URL!
	public let		restApiTokenEndpoint	: URL!
	public let		restApiPublicEndpoint	: URL!
	public let		issuer					: URL!
	private var		walletChains_			: [String]
	private let		scopesDefault			: [String]
	private let		scopesOptional			: [String]
	private let		walletFamilies_			: [String : Int64]
	private let		walletSources_			: [String : Int64]
	private let		identityProviders_		: [String]
	
	public lazy var scopes					: [String]				= { scopesDefault + scopesOptional 											}()
	public lazy var walletFamilies			: [WalletFamily]		= { walletFamilies_.map		{ WalletFamily(id: $0.value, name: $0.key) }	}()
	public lazy var walletSources			: [WalletSource]		= { walletSources_.map		{ WalletSource(id: $0.value, name: $0.key) }	}()
	public lazy var walletChains			: [Int64]				= { walletChains_.map		{ Int64($0)!}									}()
	public lazy var identityProviders		: [IdentityProvider]	= { identityProviders_.map	{ IdentityProvider(name: $0)}					}()
	
	//**************************************************************************************************
	//	OpenIDConfiguration.CodingKeys
	//--------------------------------------------------------------------------------------------------
	private enum CodingKeys : String, CodingKey {
		case authEndpoint			= "authorization_endpoint"
		case tokenEndpoint			= "token_endpoint"
		case introspectionEndpoint	= "introspection_endpoint"
		case userInfoEndpoint		= "userinfo_endpoint"
		case revokeEndpoint			= "revocation_endpoint"
		case endSessionEndpoint		= "end_session_endpoint"
		case restApiTokenEndpoint	= "rest_api_token_endpoint"
		case restApiPublicEndpoint	= "rest_api_public_endpoint"
		case issuer					= "issuer"
		case walletChains_			= "wallet_chain"
		case scopesDefault			= "client_scopes_default"
		case scopesOptional			= "client_scopes_optional"
		case walletFamilies_		= "wallet_family"
		case walletSources_			= "wallet_source"
		case identityProviders_		= "identity_providers"
	}
	//==================================================================================================
	//	isValid
	//--------------------------------------------------------------------------------------------------
	public var isValid : Bool {
		!(authEndpoint == nil
		|| tokenEndpoint == nil
		|| introspectionEndpoint == nil
		|| userInfoEndpoint == nil
		|| revokeEndpoint == nil
		|| restApiTokenEndpoint == nil
		|| restApiPublicEndpoint == nil
		|| issuer == nil
		|| scopes.count == 0)
	}
	//==================================================================================================
	//	LoadOpenIDConfiguration(ProviderInfo: ProviderInfo)
	//--------------------------------------------------------------------------------------------------
	public static func LoadOpenIDConfiguration(providerInfo:	ProviderInfo,
											   urlSession:		URLSession = URLSession.shared) async throws -> OpenIDConfiguration {
		var urlComponents		= URLComponents()
		urlComponents.scheme	= providerInfo.scheme
		urlComponents.host		= providerInfo.host
		urlComponents.port		= Int(providerInfo.port)
		urlComponents.path		= "/auth/realms/HyperID/.well-known/openid-configuration"
		do {
			let url				= urlComponents.url!
			let (data, _) = try await urlSession.data(from: url)
			guard !data.isEmpty else { throw HyperIDAPIBaseError.serverMaintenance }
			let jsonDecoder = JSONDecoder()
			do {
				let openIDConfiguration = try jsonDecoder.decode(OpenIDConfiguration.self, from: data)
				if !openIDConfiguration.isValid {
					throw HyperIDAPIBaseError.serverMaintenance
				}
				return openIDConfiguration
			} catch let error as HyperIDAPIBaseError { throw error }
			catch {
				throw HyperIDAPIBaseError.serverMaintenance
			}
		} catch let error as HyperIDAPIBaseError { throw error }
		catch {
			throw HyperIDAPIBaseError.networkingError(description: String(describing: error))
		}
	}
}

//**************************************************************************************************
//	WalletSource
//--------------------------------------------------------------------------------------------------
public enum WalletSource : Equatable {
	case walletConnect
	case metamask
	case phantom
	case cyberWallet
	case api
	case cyberWalletDefault
	case custom(name: String, id: Int64)
	
	//==================================================================================================
	//	errorDescription
	//--------------------------------------------------------------------------------------------------
	init(id: Int64, name: String) {
		switch id {
		case 0:
			self = .walletConnect
		case 1:
			self = .metamask
		case 2:
			self = .phantom
		case 3:
			self = .cyberWallet
		case 4:
			self = .api
		case 5:
			self = .cyberWalletDefault
		default:
			self = .custom(name: name, id: id)
		}
	}
	//==================================================================================================
	//	id
	//--------------------------------------------------------------------------------------------------
	public var id : Int64 {
		switch self {
		case .walletConnect:
			0
		case .metamask:
			1
		case .phantom:
			2
		case .cyberWallet:
			3
		case .api:
			4
		case .cyberWalletDefault:
			5
		case .custom(name: _, id: let id):
			id
		}
	}
	//==================================================================================================
	//	== operator
	//--------------------------------------------------------------------------------------------------
	public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
}

//**************************************************************************************************
//	WalletFamily
//--------------------------------------------------------------------------------------------------
public enum WalletFamily : Equatable{
	case ethereum
	case solana
	case custom(name: String, id: Int64)
	
	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	init(id: Int64, name: String) {
		switch id {
		case 0:
			self = .ethereum
		case 1:
			self = .solana
		default:
			self = .custom(name: name, id: id)
		}
	}
	//==================================================================================================
	//	id
	//--------------------------------------------------------------------------------------------------
	public var id : Int64 {
		switch self {
		case .ethereum:
			0
		case .solana:
			1
		case .custom(name: _, id: let id):
			id
		}
	}
	//==================================================================================================
	//	== operator
	//--------------------------------------------------------------------------------------------------
	public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
}

//**************************************************************************************************
//	WalletFamily
//--------------------------------------------------------------------------------------------------
public enum IdentityProvider : Equatable {
	case gitHub
	case discord
	case twitter
	case reddit
	case telegram
	case kakao
	case google
	case microsoft
	case tiktok
	case twitch
	case apple
	case custom(name: String)
	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	init(name: String) {
		switch name {
		case "github":
			self = .gitHub
		case "discord":
			self = .discord
		case "twitter":
			self = .twitter
		case "reddit":
			self = .reddit
		case "telegram":
			self = .telegram
		case "kakao":
			self = .kakao
		case "google":
			self = .google
		case "microsoft":
			self = .microsoft
		case "tiktok":
			self = .tiktok
		case "twitch":
			self = .twitch
		case "apple":
			self = .apple
		default:
			self = .custom(name: name)
		}
	}
	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	public var name : String {
		switch self {
		case .gitHub:
			"github"
		case .discord:
			"discord"
		case .twitter:
			"twitter"
		case .reddit:
			"reddit"
		case .telegram:
			"telegram"
		case .kakao:
			"kakao"
		case .google:
			"google"
		case .microsoft:
			"microsoft"
		case .tiktok:
			"tiktok"
		case .twitch:
			"twitch"
		case .apple:
			"apple"
		case .custom(name: let name):
			name
		}
	}
	//==================================================================================================
	//	== operator
	//--------------------------------------------------------------------------------------------------
	public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.name == rhs.name
	}
}
