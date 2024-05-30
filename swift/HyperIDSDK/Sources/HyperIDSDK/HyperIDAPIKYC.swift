import Foundation

//**************************************************************************************************
//	MARK: HyperIDAPIKYC
//--------------------------------------------------------------------------------------------------
public class HyperIDAPIKYC : HyperIDAPIBase {
	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	public override init(providerInfo: ProviderInfo? = ProviderInfo.production,
						 openIDConfiguration: OpenIDConfiguration? = nil,
						 urlSession: URLSession! = URLSession.shared) async throws {
		try await super.init(providerInfo: providerInfo, openIDConfiguration: openIDConfiguration, urlSession: urlSession)
	}
	//==================================================================================================
	//	getUserKYCStatusInfo
	//--------------------------------------------------------------------------------------------------
	public func getUserKYCStatusInfo(kycVerificationLevel:	KYCVerificationLevel,
									 accessToken:			String) async throws -> UserKYCStatusInfo? {
		guard !accessToken.isEmpty else {
			throw HyperIDAPIBaseError.invalidAccessToken
		}
		var urlRequest = HyperIDRequestUtils.constructBaseRequest(openIDConfiguration.restApiTokenEndpoint.appendingPathComponent("kyc/user/status-get"),
																  accessToken: accessToken)
		let httpBodyData : [String : Any] = [
			"verification_level":	kycVerificationLevel.rawValue
		]
		do {
			urlRequest.httpBody = try JSONSerialization.data(withJSONObject: httpBodyData)
			let (data, response) = try await urlSession.data(for: urlRequest)
			guard let httpResponse = response as? HTTPURLResponse,
				  (200..<300).contains(httpResponse.statusCode) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			if data.count > 0 {
				guard let userKYCStatusInfoResponse = try? JSONDecoder().decode(UserKYCStatusInfoResponse.self, from: data) else {
					throw HyperIDAPIBaseError.serverMaintenance
				}
				return try userKYCStatusInfoResponse.factoryUserKYCStatusInfo()
			} else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
		} catch let error as HyperIDAPIBaseError {
			throw error
		} catch {
			throw HyperIDAPIBaseError.networkingError(description: "\(error.localizedDescription)")
		}
	}
	//==================================================================================================
	//	getUserKYCStatusTopLevelInfo
	//--------------------------------------------------------------------------------------------------
	public func getUserKYCStatusTopLevelInfo(accessToken: String) async throws -> UserKYCStatusTopLevelInfo? {
		guard !accessToken.isEmpty else {
			throw HyperIDAPIBaseError.invalidAccessToken
		}
		let urlRequest = HyperIDRequestUtils.constructBaseRequest(openIDConfiguration.restApiTokenEndpoint.appendingPathComponent("kyc/user/status-top-level-get"),
																  accessToken: accessToken)
		do {
			let (data, response) = try await urlSession.data(for: urlRequest)
			guard let httpResponse = response as? HTTPURLResponse,
				  (200..<300).contains(httpResponse.statusCode) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			if data.count > 0 {
				guard let userKYCStatusTopLevelInfoResponse = try? JSONDecoder().decode(UserKYCStatusTopLevelInfoResponse.self, from: data) else {
					throw HyperIDAPIBaseError.serverMaintenance
				}
				return try userKYCStatusTopLevelInfoResponse.factoryUserKYCTopLevelInfo()
			} else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
		} catch let error as HyperIDAPIBaseError {
			throw error
		} catch {
			throw HyperIDAPIBaseError.networkingError(description: "\(error.localizedDescription)")
		}
	}
}
