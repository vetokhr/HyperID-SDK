import Foundation

//**************************************************************************************************
//	MARK: HyperIDSDKBaseAPI
//--------------------------------------------------------------------------------------------------
open class HyperIDAPIBase {
	public let	openIDConfiguration	: OpenIDConfiguration
	public let	urlSession			: URLSession!
	
	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	public init(providerInfo		: ProviderInfo?			= ProviderInfo.production,
				openIDConfiguration	: OpenIDConfiguration?	= nil,
				urlSession			: URLSession! = URLSession.shared) async throws {
		
		self.urlSession				= urlSession
		guard providerInfo != nil
				|| (openIDConfiguration != nil && openIDConfiguration!.isValid)		else { throw HyperIDAPIBaseError.invalidProviderInfo	}
		if !(openIDConfiguration?.isValid ?? false) {
			self.openIDConfiguration = try await OpenIDConfiguration.LoadOpenIDConfiguration(providerInfo:	providerInfo!,
																							 urlSession:	urlSession)
		} else {
			self.openIDConfiguration = openIDConfiguration!
		}
	}
}
