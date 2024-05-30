import Foundation

//**************************************************************************************************
//	MARK: HyperIDSDK
//--------------------------------------------------------------------------------------------------
public class HyperIDSDK : HyperIDAPIBase {
	var	hyperIDAPIAuth 		: HyperIDAPIAuth!
	var	hyperIDAPIKYC		: HyperIDAPIKYC!
	var	hyperIDAPIMFA		: HyperIDAPIMFA!
	var hyperIDAPIStorage	: HyperIDAPIStorage!
	
	//==================================================================================================
	//	authorization state
	//--------------------------------------------------------------------------------------------------
	public var isAuthorized				: Bool					{ hyperIDAPIAuth.isAuthorized										}
	public var authRestoreInfo			: String?				{ hyperIDAPIAuth.isAuthorized ? hyperIDAPIAuth.refreshToken	:	nil	}
	public var providerConfiguration	: OpenIDConfiguration	{ hyperIDAPIAuth.openIDConfiguration								}
	
	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	public init(clientInfo			: ClientInfo,
				authRestoreInfo		: String?				= nil,
				providerInfo		: ProviderInfo			= ProviderInfo.production,
				urlSession			: URLSession! = URLSession.shared) async throws {
		try await super.init(providerInfo:			providerInfo,
							 openIDConfiguration:	nil,
							 urlSession:			urlSession)
		try await hyperIDAPIAuth	= HyperIDAPIAuth(clientInfo:			clientInfo,
													 refreshToken:			authRestoreInfo,
													 openIDConfiguration:	openIDConfiguration,
													 urlSession:			urlSession)
		try await hyperIDAPIKYC		= HyperIDAPIKYC(openIDConfiguration:	openIDConfiguration,
													urlSession:				urlSession)
		try await hyperIDAPIMFA		= HyperIDAPIMFA(openIDConfiguration:	openIDConfiguration,
													urlSession:				urlSession)
		try await hyperIDAPIStorage	= HyperIDAPIStorage(openIDConfiguration:	openIDConfiguration,
														urlSession:				urlSession)
	}
}

//**************************************************************************************************
//	MARK: HyperIDSDK - auth
//--------------------------------------------------------------------------------------------------
public extension HyperIDSDK {
	//==================================================================================================
	//	startSignInWeb2
	//--------------------------------------------------------------------------------------------------
	func startSignInWeb2(kycVerificationLevel:	KYCVerificationLevel? = nil) throws -> URL {
		try hyperIDAPIAuth.startSignInWeb2(kycVerificationLevel: kycVerificationLevel)
	}
	//==================================================================================================
	//	startSignInWeb3
	//--------------------------------------------------------------------------------------------------
	func startSignInWeb3(walletFamily:			WalletFamily? = .ethereum,
						 kycVerificationLevel:	KYCVerificationLevel? = nil) throws -> URL {
		try hyperIDAPIAuth.startSignInWeb3(walletFamily:			walletFamily,
										   kycVerificationLevel:	kycVerificationLevel)
	}
	//==================================================================================================
	//	startSignInUsingWallet
	//--------------------------------------------------------------------------------------------------
	func startSignInUsingWallet(walletGetMode	: WalletGetMode = .walletGetFast,
								walletFamily	: WalletFamily? = .ethereum) throws -> URL {
		try hyperIDAPIAuth.startSignInUsingWallet(walletGetMode:	walletGetMode,
												  walletFamily:		walletFamily)
	}
	//==================================================================================================
	//	startSignInGuestUpgrade
	//--------------------------------------------------------------------------------------------------
	func startSignInGuestUpgrade() throws -> URL {
		try hyperIDAPIAuth.startSignInGuestUpgrade()
	}
	//==================================================================================================
	//	startSignInIdentityProvider
	//--------------------------------------------------------------------------------------------------
	func startSignInIdentityProvider(identityProvider		: IdentityProvider,
									 kycVerificationLevel	: KYCVerificationLevel? = nil) throws -> URL {
		try hyperIDAPIAuth.startSignInIdentityProvider(identityProvider:		identityProvider,
													   kycVerificationLevel:	kycVerificationLevel)
	}
	//==================================================================================================
	//	completeSignIn
	//--------------------------------------------------------------------------------------------------
	func completeSignIn(redirectURL : URL) async throws {
		do {
			try await hyperIDAPIAuth.exchangeToTokens(redirectURL: redirectURL)
		} catch HyperIDAPIAuthError.tokenExchangeInvalidGrant(description: _) {
			throw HyperIDAPIAuthError.authorizationInvalidRedirectURLError(description: "URL invalid to complete authorization. Please restart authorization")
		}
	}
	//==================================================================================================
	//	signOut
	//--------------------------------------------------------------------------------------------------
	func signOut() async throws {
		try await hyperIDAPIAuth.logout()
	}
	//==================================================================================================
	//	getUserInfo
	//--------------------------------------------------------------------------------------------------
	func getUserInfo() async throws -> UserInfo {
		return try await processAuthorizedAction { _ in try await hyperIDAPIAuth.getUserInfo() }
	}
}

//**************************************************************************************************
//	MARK: HyperIDSDK - KYC
//--------------------------------------------------------------------------------------------------
public extension HyperIDSDK {
	//==================================================================================================
	//	getUserKYCStatusInfo
	//--------------------------------------------------------------------------------------------------
	func getUserKYCStatusInfo(kycVerificationLevel:	KYCVerificationLevel = .basic) async throws -> UserKYCStatusInfo? {
		try await processAuthorizedAction {
			try await hyperIDAPIKYC.getUserKYCStatusInfo(kycVerificationLevel: .basic, accessToken: $0)
		}
	}
	//==================================================================================================
	//	getUserKYCStatusTopLevelInfo
	//--------------------------------------------------------------------------------------------------
	func getUserKYCStatusTopLevelInfo() async throws -> UserKYCStatusTopLevelInfo? {
		try await processAuthorizedAction {
			try await hyperIDAPIKYC.getUserKYCStatusTopLevelInfo(accessToken: $0)
		}
	}
}

//**************************************************************************************************
//	MARK: HyperIDSDK - MFA
//--------------------------------------------------------------------------------------------------
public extension HyperIDSDK {
	//==================================================================================================
	//	checkMFAAvailability
	//--------------------------------------------------------------------------------------------------
	func checkMFAAvailability() async throws -> Bool {
		try await processAuthorizedAction {
			try await hyperIDAPIMFA.checkAvailability(accessToken: $0)
		}
	}
	//==================================================================================================
	//	startMFATransaction
	//--------------------------------------------------------------------------------------------------
	func startMFATransaction(question		: String,
							 controlCode	: Int) async throws -> Int {
		try await processAuthorizedAction {
			try await hyperIDAPIMFA.startTransaction(question:		question,
													 controlCode:	controlCode,
													 accessToken:	$0)
		}
	}
	//==================================================================================================
	//	getMFATransactionStatus
	//--------------------------------------------------------------------------------------------------
	func getMFATransactionStatus(transactionId : Int) async throws -> MFATransactionStatus? {
		try await processAuthorizedAction {
			try await hyperIDAPIMFA.getTransactionStatus(transactionId:	transactionId,
														 accessToken:	$0)
		}
	}
	//==================================================================================================
	//	cancelMFATransaction
	//--------------------------------------------------------------------------------------------------
	func cancelMFATransaction(transactionId : Int) async throws {
		try await processAuthorizedAction {
			try await hyperIDAPIMFA.cancelTransaction(transactionId:	transactionId,
													  accessToken:		$0)
		}
	}
}

//**************************************************************************************************
//	MARK: HyperIDSDK - Storage
//--------------------------------------------------------------------------------------------------
public extension HyperIDSDK {
	//==================================================================================================
	//	getUserKeysList
	//--------------------------------------------------------------------------------------------------
	func getUserKeysList(storage: HyperIDStorage) async throws -> (keysPrivate: [String], keysPublic: [String]) {
		try await processAuthorizedAction {
			try await hyperIDAPIStorage.getUserKeysList(storage: storage, accessToken: $0)
		}
	}
	//==================================================================================================
	//	getUserSharedKeysList
	//--------------------------------------------------------------------------------------------------
	func getUserSharedKeysList(storage: HyperIDStorage) async throws -> [String] {
		try await processAuthorizedAction {
			try await hyperIDAPIStorage.getUserSharedKeysList(storage: storage, accessToken: $0)
		}
	}
	//==================================================================================================
	//	setUserData
	//--------------------------------------------------------------------------------------------------
	func setUserData(_ value		: (key: String, value: String),
					 dataScope		: UserDataAccessScope = .public,
					 storage		: HyperIDStorage) async throws {
		try await processAuthorizedAction {
			try await hyperIDAPIStorage.setUserData(value, dataScope: dataScope, storage: storage, accessToken: $0)
		}
	}
	//==================================================================================================
	//	getUserData
	//--------------------------------------------------------------------------------------------------
	func getUserData(_ key			: String,
					 storage		: HyperIDStorage) async throws -> String? {
		try await processAuthorizedAction {
			try await hyperIDAPIStorage.getUserData(key, storage: storage, accessToken: $0)
		}
	}
	//==================================================================================================
	//	deleteUserData
	//--------------------------------------------------------------------------------------------------
	func deleteUserData(_ key		: String,
						storage		: HyperIDStorage) async throws {
		try await processAuthorizedAction {
			try await hyperIDAPIStorage.deleteUserData(key, storage: storage, accessToken: $0)
		}
	}
}

//**************************************************************************************************
//	MARK: HyperIDSDK - private
//--------------------------------------------------------------------------------------------------
private extension HyperIDSDK {
	//==================================================================================================
	//	processAuthorizedAction
	//--------------------------------------------------------------------------------------------------
	func processAuthorizedAction<T>(action : (_ accessToken: String) async throws -> T) async throws -> T {
		if isAuthorized {
			do {
				if let accessToken = hyperIDAPIAuth.accessToken {
					return try await action(accessToken)
				} else {
					try await hyperIDAPIAuth.refreshTokens()
					return try await action(hyperIDAPIAuth.accessToken!)
				}
			} catch HyperIDAPIBaseError.invalidAccessToken {
				do {
					try await hyperIDAPIAuth.refreshTokens()
					return try await action(hyperIDAPIAuth.accessToken!)
				} catch HyperIDAPIBaseError.invalidAccessToken,
						HyperIDAPIAuthError.tokenExchangeInvalidGrant(description: _) {
					throw HyperIDSDKError.authorizationExpired
				}
			} catch HyperIDAPIAuthError.tokenExchangeInvalidGrant(description: _) {
				throw HyperIDSDKError.authorizationExpired
			}
		} else {
			throw HyperIDSDKError.authorizationExpired
		}
	}
}
