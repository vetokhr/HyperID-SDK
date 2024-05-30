import Foundation

//**************************************************************************************************
//	MARK: KYCVerificationLevel
//--------------------------------------------------------------------------------------------------
public enum KYCVerificationLevel {
	case unsupported(code : Int)
	
	case basic
	case full
	
	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	init(rawValue : Int) {
		switch rawValue {
			case 3:
				self = .basic
			case 4:
				self = .full
			default:
				self = .unsupported(code: rawValue)
		}
	}
	//==================================================================================================
	//	rawValue
	//--------------------------------------------------------------------------------------------------
	var rawValue : Int {
		switch self {
		case .unsupported(code: let code):
			return code
		case .basic:
			return 3
		case .full:
			return 4
		}
	}
}
