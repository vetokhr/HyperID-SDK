import XCTest
import HyperIDSDK

//**************************************************************************************************
//	HyperIDSDKTests
//--------------------------------------------------------------------------------------------------
final class HyperIDSDKTests: XCTestCase {
	var hyperIdSDK : HyperIDSDK!
	//==================================================================================================
	//	setUpWithError
	//--------------------------------------------------------------------------------------------------
	override func setUpWithError() throws {
		print("[HyperIDSDKAuthTestBase] Starting async library init")
		var errorCatched : Error?
		let errorSaver = { errorCatched = $0 }
		let expectation = expectation(description: "setup hyperIdAuth")
		Task {
			do {
				let clientInfo = ClientInfo(clientId:               "your_client_id",
											redirectURL:            "custom_protocol://localhost:42",
											authorizationMethod:	.clientSecret(secret: "your_secret"))
				hyperIdSDK = try await HyperIDSDK(clientInfo:       clientInfo,
												  authRestoreInfo:  "data stored from previous run",
												  providerInfo:	    ProviderInfo.sandbox,
												  urlSession:       URLSession.shared)
			} catch {
				errorSaver(error)
			}
			expectation.fulfill()
			print("[HyperIDSDKAuthTestBase] async library init finished")
		}
		wait(for: [expectation])
		if let errorCatched = errorCatched
		{
			print("[HyperIDSDKAuthTestBase] init error occured: \(errorCatched.localizedDescription)")
		}
		else
		{
			print("[HyperIDSDKAuthTestBase] Starting test")
		}
	}
	//==================================================================================================
	//	printRefreshToken
	//--------------------------------------------------------------------------------------------------
	func printRefreshToken() {
		let refreshToken = hyperIdSDK.authRestoreInfo
		print("[HyperIDSDKAuthSecretTest][testAuthorizationStartWithIdentityProvider] refreshToken:\(refreshToken!)")
	}
	//==================================================================================================
	//	testAuthorizationStartSignIn
	//--------------------------------------------------------------------------------------------------
	func testAuthorizationStartSignIn() throws {
		let url = try hyperIdSDK.startSignInWeb2()
		print("[HyperIDSDKAuthSecretTest][testAuthorizationStartSignIn] url:\(url.absoluteString)")
	}
	//==================================================================================================
	//	testAuthorizationComplete
	//--------------------------------------------------------------------------------------------------
	func testCompleteSignIn() async throws {
		let redirectURL = "https://localhost:4200/?locale=en&session_state=73f78a78-9d12-4f2d-bccf-4d600df63d6b&code=c2c25901-9f95-440b-8c41-24272f0b1bb9.73f78a78-9d12-4f2d-bccf-4d600df63d6b.e75e8ad5-37aa-40dd-af4f-31139d82d94b.0"
		try await hyperIdSDK.completeSignIn(redirectURL: URL(string: redirectURL)!)
		printRefreshToken()
		let userInfo = try await hyperIdSDK.getUserInfo()
		XCTAssert(hyperIdSDK.isAuthorized)
	}
	//==================================================================================================
	//	testGetUserInfo
	//--------------------------------------------------------------------------------------------------
	func testGetUserInfo() async throws {
		let userInfo = try await hyperIdSDK.getUserInfo()
		printRefreshToken()
		let string = String(data: try JSONEncoder().encode(userInfo), encoding: .utf8)!
		XCTAssert(!string.isEmpty)
	}
	//==================================================================================================
	//	testLogout
	//--------------------------------------------------------------------------------------------------
	func testLogout() async throws {
		try await hyperIdSDK.signOut()
		XCTAssert(!hyperIdSDK.isAuthorized)
	}
	//==================================================================================================
	//	testUserKYCStatusInfoGet
	//--------------------------------------------------------------------------------------------------
	func testUserKYCStatusInfoGet() async throws {
		let result = try await hyperIdSDK.getUserKYCStatusInfo(kycVerificationLevel: .full)
		printRefreshToken()
		print(result!)
	}
	//==================================================================================================
	//	testUserKYCStatusTopLevelInfoGet
	//--------------------------------------------------------------------------------------------------
	func testUserKYCStatusTopLevelInfoGet() async throws {
		let result = try await hyperIdSDK.getUserKYCStatusTopLevelInfo()
		printRefreshToken()
	}
	//==================================================================================================
	//	testGetStorageKeys
	//--------------------------------------------------------------------------------------------------
	func testGetStorageKeys() async throws {
		var result = try await hyperIdSDK.getUserKeysList(storage: .email)
		print("private: \(result.keysPrivate)")
		print("public: \(result.keysPublic)")
		result = try await hyperIdSDK.getUserKeysList(storage: .userID)
		print("private: \(result.keysPrivate)")
		print("public: \(result.keysPublic)")
		result = try await hyperIdSDK.getUserKeysList(storage: .wallet(address: "0xc8abaF03F2dD39A344a412478164cB3FA2dd5D0a"))
		print("private: \(result.keysPrivate)")
		print("public: \(result.keysPublic)")
		result = try await hyperIdSDK.getUserKeysList(storage: .identityProvider(.google))
		print("private: \(result.keysPrivate)")
		print("public: \(result.keysPublic)")
		printRefreshToken()
	}
	//==================================================================================================
	//	testSetStorageData
	//--------------------------------------------------------------------------------------------------
	func testSetStorageData() async throws {
		try await hyperIdSDK.setUserData((key: "testKeyPrivateEmail", value: "testValuePrivate"), dataScope: .private, storage: .email)
		try await hyperIdSDK.setUserData((key: "testKeyPublicEmail", value: "testValuePublic"), dataScope: .public, storage: .email)
		try await hyperIdSDK.setUserData((key: "testKeyPrivateUserId", value: "testValuePrivate"), dataScope: .private, storage: .userID)
		try await hyperIdSDK.setUserData((key: "testKeyPublicUserId", value: "testValuePublic"), dataScope: .public, storage: .userID)
		try await hyperIdSDK.setUserData((key: "testKeyPrivateWallet", value: "testValuePrivate"), dataScope: .private, storage: .wallet(address: "0xc8abaF03F2dD39A344a412478164cB3FA2dd5D0a"))
		try await hyperIdSDK.setUserData((key: "testKeyPublicWallet", value: "testValuePublic"), dataScope: .public, storage: .wallet(address: "0xc8abaF03F2dD39A344a412478164cB3FA2dd5D0a"))
		try await hyperIdSDK.setUserData((key: "testKeyPrivateGoogle1", value: "testValuePrivate"), dataScope: .private, storage: .identityProvider(.google))
		try await hyperIdSDK.setUserData((key: "testKeyPublicGoogle1", value: "testValuePublic"), dataScope: .public, storage: .identityProvider(.google))
		printRefreshToken()
	}
	//==================================================================================================
	//	testGetStorageData
	//--------------------------------------------------------------------------------------------------
	func testGetStorageData() async throws {
		var string = try await hyperIdSDK.getUserData("testKeyPrivateEmail", storage: .email)
		print(string)
		string = try await hyperIdSDK.getUserData("testKeyPrivateUserId", storage: .userID)
		print(string)
		string = try await hyperIdSDK.getUserData("testKeyPrivateWallet", storage: .wallet(address: "0xc8abaF03F2dD39A344a412478164cB3FA2dd5D0a"))
		print(string)
		string = try await hyperIdSDK.getUserData("testKeyPublicGoogle", storage: .identityProvider(.google))
		print(string)
		printRefreshToken()
	}
	//==================================================================================================
	//	testDeleteStorageData
	//--------------------------------------------------------------------------------------------------
	func testDeleteStorageData() async throws {
		try await hyperIdSDK.deleteUserData("testKeyPrivateEmail", storage: .email)
		try await hyperIdSDK.deleteUserData("testKeyPrivateUserId", storage: .userID)
		try await hyperIdSDK.deleteUserData("testKeyPrivateWallet", storage: .wallet(address: "0xc8abaF03F2dD39A344a412478164cB3FA2dd5D0a"))
		try await hyperIdSDK.deleteUserData("testKeyPublicGoogle1", storage: .identityProvider(.google))
	}
	//==================================================================================================
	//	testCheckAvaibility
	//--------------------------------------------------------------------------------------------------
	func testCheckAvaibility() async throws {
		let result = try await hyperIdSDK.checkMFAAvailability()
		print(result)
	}
	//==================================================================================================
	//	testStartMFATransaction
	//--------------------------------------------------------------------------------------------------
	func testStartMFATransaction() async throws {
		let transactionId = try await hyperIdSDK.startMFATransaction(question: "Will you marry pig?", controlCode: 23)
		print(transactionId)
	}
	//==================================================================================================
	//	testStartMFATransaction
	//--------------------------------------------------------------------------------------------------
	func testGetMFATransactionStatus() async throws {
		let status = try await hyperIdSDK.getMFATransactionStatus(transactionId: 8222)
		print(status!)
	}
	//==================================================================================================
	//	testStartMFATransaction
	//--------------------------------------------------------------------------------------------------
	func testCancelMFATransaction() async throws{
		try await hyperIdSDK.cancelMFATransaction(transactionId: 8225)
	}
}
