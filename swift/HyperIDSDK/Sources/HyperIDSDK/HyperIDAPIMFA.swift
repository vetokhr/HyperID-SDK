import Foundation

//**************************************************************************************************
//	MARK: HyperIDAPIMFA
//--------------------------------------------------------------------------------------------------
public class HyperIDAPIMFA : HyperIDAPIBase {
	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	public override init(providerInfo: ProviderInfo? = ProviderInfo.production,
						 openIDConfiguration: OpenIDConfiguration? = nil,
						 urlSession: URLSession! = URLSession.shared) async throws {
		try await super.init(providerInfo: providerInfo, openIDConfiguration: openIDConfiguration, urlSession: urlSession)
	}
	//==================================================================================================
	//	checkAvailability
	//--------------------------------------------------------------------------------------------------
	public func checkAvailability(accessToken: String) async throws -> Bool {
		guard !accessToken.isEmpty else {
			throw HyperIDAPIBaseError.invalidAccessToken
		}
		let urlRequest = HyperIDRequestUtils.constructBaseRequest(openIDConfiguration.restApiTokenEndpoint.appendingPathComponent("mfa-client/availability-check"),
																  accessToken: accessToken)
		do {
			let (data, response) = try await urlSession.data(for: urlRequest)
			guard let httpResponse = response as? HTTPURLResponse,
				  (200..<300).contains(httpResponse.statusCode) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			guard let availabilityCheckResponse = try? JSONDecoder().decode(MFAAvailablilityCheckRepsonse.self, from: data) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			try availabilityCheckResponse.validate()
			return availabilityCheckResponse.isAvailable
		} catch let error as HyperIDAPIMFAError {
			throw error
		} catch let error as HyperIDAPIBaseError {
			throw error
		} catch {
			throw HyperIDAPIBaseError.networkingError(description: "\(error.localizedDescription)")
		}
	}
	//==================================================================================================
	//	startTransaction
	//--------------------------------------------------------------------------------------------------
	public func startTransaction(question		: String,
								 controlCode	: Int,
								 accessToken	: String) async throws -> Int {
		guard !accessToken.isEmpty else {
			throw HyperIDAPIBaseError.invalidAccessToken
		}
		guard (0...99).contains(controlCode) else {
			throw HyperIDAPIMFAError.controlCodeInvalidValue
		}
		var urlRequest = HyperIDRequestUtils.constructBaseRequest(openIDConfiguration.restApiTokenEndpoint.appendingPathComponent("mfa-client/transaction/start/v2"),
																  accessToken: accessToken)
		let values : [String : Any] = [
			"version" : 1,
			"action" : [
				"type"			: "question",
				"action_info"	: question,
			]
		]
		let valuesStr = String(data: try! JSONSerialization.data(withJSONObject: values), encoding: .utf8)
		let httpRequest : [String : Any] = [
			"template_id" : 4,
			"code" : "\(String(format: "%02d", controlCode))",
			"values" : valuesStr!,
		]
		do {
			urlRequest.httpBody = try JSONSerialization.data(withJSONObject: httpRequest)
			let (data, response) = try await urlSession.data(for: urlRequest)
			guard let httpResponse = response as? HTTPURLResponse,
				  (200..<300).contains(httpResponse.statusCode) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			guard let transactionStartResponse = try? JSONDecoder().decode(MFATransactionStartResponse.self, from: data) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			try transactionStartResponse.validate()
			return transactionStartResponse.transactionId
		} catch let error as HyperIDAPIMFAError {
			throw error
		} catch let error as HyperIDAPIBaseError {
			throw error
		} catch {
			throw HyperIDAPIBaseError.networkingError(description: "\(error.localizedDescription)")
		}
	}
	//==================================================================================================
	//	getTransactionStatus
	//--------------------------------------------------------------------------------------------------
	public func getTransactionStatus(transactionId : Int,
									 accessToken : String) async throws -> MFATransactionStatus? {
		guard !accessToken.isEmpty else {
			throw HyperIDAPIBaseError.invalidAccessToken
		}
		var urlRequest = HyperIDRequestUtils.constructBaseRequest(openIDConfiguration.restApiTokenEndpoint.appendingPathComponent("mfa-client/transaction/status-get"),
																  accessToken: accessToken)
		let httpRequest : [String : Any] = [
			"transaction_id" : transactionId
		]
		do {
			urlRequest.httpBody = try JSONSerialization.data(withJSONObject: httpRequest)
			let (data, response) = try await urlSession.data(for: urlRequest)
			guard let httpResponse = response as? HTTPURLResponse,
				  (200..<300).contains(httpResponse.statusCode) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			guard let transactionStatusGetResponse = try? JSONDecoder().decode(MFATransactionStatusResponse.self, from: data) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			try transactionStatusGetResponse.validate()
			return transactionStatusGetResponse.status
		} catch let error as HyperIDAPIMFAError {
			throw error
		} catch let error as HyperIDAPIBaseError {
			throw error
		} catch {
			throw HyperIDAPIBaseError.networkingError(description: "\(error.localizedDescription)")
		}
	}
	//==================================================================================================
	//	cancelTransaction
	//--------------------------------------------------------------------------------------------------
	public func cancelTransaction(transactionId : Int,
								  accessToken : String) async throws {
		guard !accessToken.isEmpty else {
			throw HyperIDAPIBaseError.invalidAccessToken
		}
		var urlRequest = HyperIDRequestUtils.constructBaseRequest(openIDConfiguration.restApiTokenEndpoint.appendingPathComponent("/mfa-client/transaction/cancel"),
																  accessToken: accessToken)
		let httpRequest : [String : Any] = [
			"transaction_id" : transactionId
		]
		do {
			urlRequest.httpBody = try JSONSerialization.data(withJSONObject: httpRequest)
			let (data, response) = try await urlSession.data(for: urlRequest)
			guard let httpResponse = response as? HTTPURLResponse,
				  (200..<300).contains(httpResponse.statusCode) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			guard let transactionCancelResponse = try? JSONDecoder().decode(MFATransactionCancelResponse.self, from: data) else {
				throw HyperIDAPIBaseError.serverMaintenance
			}
			try transactionCancelResponse.validate()
		} catch let error as HyperIDAPIMFAError {
			throw error
		} catch let error as HyperIDAPIBaseError {
			throw error
		} catch {
			throw HyperIDAPIBaseError.networkingError(description: "\(error.localizedDescription)")
		}
	}
}
