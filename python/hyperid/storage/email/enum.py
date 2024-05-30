from enum import Enum

class UserDataSetByEmailResult(Enum):
	FAIL_BY_KEY_INVALID					= -7
	FAIL_BY_KEY_ACCESS_DENIED			= -6
	FAIL_BY_INVALID_PARAMETERS			= -5
	FAIL_BY_SERVICE_TEMPORARY_NOT_VALID	= -4
	FAIL_BY_ACCESS_DENIED				= -3
	FAIL_BY_TOKEN_EXPIRED				= -2
	FAIL_BY_TOKEN_INVALID				= -1
	SUCCESS								= 0

class UserDataGetByEmailResult(Enum):
	FAIL_BY_INVALID_PARAMETERS			= -5
	FAIL_BY_SERVICE_TEMPORARY_NOT_VALID	= -4
	FAIL_BY_ACCESS_DENIED				= -3
	FAIL_BY_TOKEN_EXPIRED				= -2
	FAIL_BY_TOKEN_INVALID				= -1
	SUCCESS								= 0
	SUCCESS_NOT_FOUND					= 1

class UserDataKeysByEmailGetResult(Enum):
	FAIL_BY_INVALID_PARAMETERS			= -5
	FAIL_BY_SERVICE_TEMPORARY_NOT_VALID	= -4
	FAIL_BY_ACCESS_DENIED				= -3
	FAIL_BY_TOKEN_EXPIRED				= -2
	FAIL_BY_TOKEN_INVALID				= -1
	SUCCESS								= 0
	SUCCESS_NOT_FOUND					= 1

class UserDataKeysByEmailDeleteResult(Enum):
	FAIL_BY_KEY_ACCESS_DENIED			= -6
	FAIL_BY_INVALID_PARAMETERS			= -5
	FAIL_BY_SERVICE_TEMPORARY_NOT_VALID	= -4
	FAIL_BY_ACCESS_DENIED				= -3
	FAIL_BY_TOKEN_EXPIRED				= -2
	FAIL_BY_TOKEN_INVALID				= -1
	SUCCESS								= 0
	SUCCESS_NOT_FOUND					= 1