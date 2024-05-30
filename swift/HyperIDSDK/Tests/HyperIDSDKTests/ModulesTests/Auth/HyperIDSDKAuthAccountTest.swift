import XCTest
import HyperIDSDK

//**************************************************************************************************
//	HyperIDSDKAuthAccountTest
//--------------------------------------------------------------------------------------------------
final class HyperIDSDKAuthAccountTest: HyperIDSDKAuthTestBase {
	//==================================================================================================
	//	FactoryHyperIDSDKAuth
	//--------------------------------------------------------------------------------------------------
	override func FactoryHyperIDAPIAuth() async throws -> HyperIDAPIAuth {
		return try await HyperIDAPIAuth(clientInfo:		ClientInfo(clientId: 			"android-sdk-test",
																   redirectURL:			"https://localhost:4200",
																   authorizationMethod:	.clientSecret(secret:	"3Sn8mPtwpaitbeTRJ9mcDNoR15kEzF9L")),
										providerInfo:	ProviderInfo.stage)
	}
	//==================================================================================================
	//	testAccessToken
	//--------------------------------------------------------------------------------------------------
	func testRefreshToken() async throws {
		try await hyperIdAuth.refreshTokens()
		XCTAssert(!(hyperIdAuth.accessToken?.isEmpty ?? true))
		XCTAssert(!(hyperIdAuth.refreshToken?.isEmpty ?? true))
	}
	//==================================================================================================
	//	testUserInfoGet
	//--------------------------------------------------------------------------------------------------
	func testUserInfoGet() async throws {
		let userInfo = try await hyperIdAuth.getUserInfo()
		print(userInfo)
	}
	//==================================================================================================
	//	logout()
	//--------------------------------------------------------------------------------------------------
	func testLogout() async throws {
		try await hyperIdAuth.logout()
	}
}
