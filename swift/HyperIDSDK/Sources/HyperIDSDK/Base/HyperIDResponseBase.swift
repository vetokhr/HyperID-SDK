import Foundation

//**************************************************************************************************
//	MARK: HyperIDResponseBase
//--------------------------------------------------------------------------------------------------
protocol HyperIDResponseBase : Validatable {
	var result	: Validatable { get }
}
//**************************************************************************************************
//	MARK: HyperIdResponseBase - impl
//--------------------------------------------------------------------------------------------------
extension HyperIDResponseBase {
	//==================================================================================================
	//	validate
	//--------------------------------------------------------------------------------------------------
	public func validate() throws {
		try result.validate()
	}
}