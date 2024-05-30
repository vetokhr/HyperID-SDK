import Foundation

//**************************************************************************************************
//	MARK: ProviderInfo
//--------------------------------------------------------------------------------------------------
public struct ProviderInfo {
	public let scheme	: String
	public let host		: String
	public let port		: UInt16
	
	//==================================================================================================
	//	isValid
	//--------------------------------------------------------------------------------------------------
	public var isValid : Bool {
		!(scheme.isEmpty
		|| host.isEmpty)
	}
	public static let sandbox		: Self = Self.init(scheme: "https", host: "login-sandbox.hypersecureid.com",	port: 443)
	public static let production	: Self = Self.init(scheme: "https", host: "login.hypersecureid.com",			port: 443)
}
