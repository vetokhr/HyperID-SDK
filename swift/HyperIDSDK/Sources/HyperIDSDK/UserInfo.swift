import Foundation

//**************************************************************************************************
//	MARK: UserInfo
//--------------------------------------------------------------------------------------------------
public class UserInfo : Decodable {
	//**************************************************************************************************
	//	MARK:  UserInfo.CodingKeys
	//--------------------------------------------------------------------------------------------------
	private enum CodingKeys : String, CodingKey {
		case userId		= "sub"
		case isGuest	= "is_guest"
		case email		= "email"
		case deviceId	= "deviceId"
		case ip			= "ip"
	}

	//**************************************************************************************************
	//	MARK:  UserInfo.Wallet
	//--------------------------------------------------------------------------------------------------
	public class Wallet : Codable {
		//**************************************************************************************************
		//	MARK: UserInfo.Wallet.CodingKeys
		//--------------------------------------------------------------------------------------------------
		private enum CodingKeys : String, CodingKey {
			case address	= "wallet_address"
			case chainId	= "wallet_chain_id"
			case source		= "wallet_source"
			case isVerified	= "is_wallet_verified"
			case family		= "wallet_family"
		}
		public var address		: String?
		public var chainId		: String?
		public var source		: String?
		public var isVerified	: Bool?
		public var family		: String?
	}
	
	public var userId 	: String?
	public var isGuest	: Bool
	public var email	: String?
	public var deviceId	: String?
	public var ip		: String?
	public var wallet	: Wallet?
	
	//==================================================================================================
	//	init
	//--------------------------------------------------------------------------------------------------
	public required init(from decoder: Decoder) throws {
		let container: KeyedDecodingContainer<UserInfo.CodingKeys> = try decoder.container(keyedBy: UserInfo.CodingKeys.self)
		self.userId		= try container.decodeIfPresent(String.self, forKey: .userId)
		self.isGuest	= (try container.decodeIfPresent(Bool.self, forKey: .isGuest)) ?? false
		self.email		= try container.decodeIfPresent(String.self, forKey: .email)
		self.deviceId	= try container.decodeIfPresent(String.self, forKey: .deviceId)
		self.ip			= try container.decodeIfPresent(String.self, forKey: .ip)
		self.wallet		= try? UserInfo.Wallet(from: decoder)
	}
}
