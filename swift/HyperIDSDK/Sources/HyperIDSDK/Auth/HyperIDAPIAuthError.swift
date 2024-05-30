import Foundation

//**************************************************************************************************
//	MARK: HyperIDAPIAuthError
//--------------------------------------------------------------------------------------------------
public enum HyperIDAPIAuthError : HyperIDSDKErrorProtocol {
	case invalidClientInfo(description : String = "")
	
	case unknownIdentityProvider(provider : String)
	case unknownWalletFamily
	case assertionTokenSignError(description : String)
	
	case authorizationInvalidRedirectURLError(description : String)
	case tokenExchangeInvalidGrant(description : String)
	//==================================================================================================
	//	errorDescription
	//--------------------------------------------------------------------------------------------------
	public var errorDescription: String? {
		switch self {
		case .invalidClientInfo(let msg):						"Invalid ClientInfo.\(msg.isEmpty ? "" : "Details \(msg)")"
		case .unknownIdentityProvider:							"Unknown indentity provider. Please use providers presented OpenIDConfiguration"
		case .unknownWalletFamily:								"Unknown wallet family. Please use default or families presented OpenIDConfiguration"
		case .assertionTokenSignError(let msg):					"Assertion token sign error: \(msg)"
		case .tokenExchangeInvalidGrant(let msg):				"Token exchange error: invalid grant. Details: \(msg)"
		case .authorizationInvalidRedirectURLError(let msg):	"Token exchange error: invalid redirect url. Details: \(msg)"
		}
	}
}
