import React, {useState, useCallback, useMemo} from 'react';
import {Alert} from 'react-native';
import {
  authorize,
  refresh,
  revoke,
  prefetchConfiguration,
  dataSet,
  dataGet,
  walletsGet,
} from 'react-native-app-auth';
import RNPickerSelect from 'react-native-picker-select';
import {
  Page,
  Button,
  ButtonContainer,
  Form,
  FormLabel,
  FormValue,
  Heading,
} from './components';

const configs = {
    authClear: {
      issuer: 'https://login.hypersecureid.com/auth/realms/HyperID',
      clientId: 'your_client_id',
      redirectUrl: 'your.custom.scheme://localhost:4200/auth/callback',
      clientSecret: "your_client_secret",
      clientAuthMethod: "basic",
      additionalParameters: {},
      scopes: ['openid', 'email', 'user_data_set', 'user_data_get'],
   
      serviceConfiguration: {
        authorizationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/auth',
        tokenEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/token',
        revocationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/revoke'
      }
    },
    authWallet: {
      issuer: 'https://login.hypersecureid.com/auth/realms/HyperID',
      clientId: 'your_client_id',
      redirectUrl: 'your.custom.scheme://localhost:4200/auth/callback',
      clientSecret: "your_client_secret",
      clientAuthMethod: "basic",
      additionalParameters: {
        flow_mode:        "4",
        wallet_get_mode:  "2"
      },
      scopes: ['openid', 'email', 'user_data_set', 'user_data_get'],
   
      serviceConfiguration: {
        authorizationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/auth',
        tokenEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/token',
        revocationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/revoke'
      }
    },
    authIdentityProvider: {
      issuer: 'https://login.hypersecureid.com/auth/realms/HyperID',
      clientId: 'your_client_id',
      redirectUrl: 'your.custom.scheme://localhost:4200/auth/callback',
      clientSecret: "your_client_secret",
      clientAuthMethod: "basic",
      additionalParameters: {
        flow_mode:          "9",
        identity_provider:  "google"
      },
      scopes: ['openid', 'email', 'user_data_set', 'user_data_get'],
   
      serviceConfiguration: {
        authorizationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/auth',
        tokenEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/token',
        revocationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/revoke'
      }
    },
    authTransaction: {
      issuer: 'https://login.hypersecureid.com/auth/realms/HyperID',
      clientId: 'your_client_id',
      redirectUrl: 'your.custom.scheme://localhost:4200/auth/callback',
      clientSecret: "your_client_secret",
      clientAuthMethod: "basic",
      additionalParameters: {
        transaction: '{"from":"0x43D192d3eC9CaEFbc92385bED8508d87E566595f","to":"0x0AeB980AB115E45409D9bA33CCffcc75995E3dfA","chain":"11155111","data":"0x70a0823100000000000000000000000043d192d3ec9caefbc92385bed8508d87e566595f"}'
      },
      scopes: ['openid', 'email', 'user_data_set', 'user_data_get'],
   
      serviceConfiguration: {
        authorizationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/auth',
        tokenEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/token',
        revocationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/revoke'
      }
    },
    authGuestUpgrade: {
      issuer: 'https://login.hypersecureid.com/auth/realms/HyperID',
      clientId: 'your_client_id',
      redirectUrl: 'your.custom.scheme://localhost:4200/auth/callback',
      clientSecret: "your_client_secret",
      clientAuthMethod: "basic",
      additionalParameters: {
        flow_mode:        "6",
      },
      scopes: ['openid', 'email', 'user_data_set', 'user_data_get'],
   
      serviceConfiguration: {
        authorizationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/auth',
        tokenEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/token',
        revocationEndpoint: 'https://login.hypersecureid.com/auth/realms/HyperID/protocol/openid-connect/revoke'
      }
    },
};

const defaultAuthState = {
  hasLoggedInOnce: false,
  provider: '',
  accessToken: '',
  accessTokenExpirationDate: '',
  refreshToken: '',
  restApiEndpoint: '',
};

const App = () => {
  const [authState, setAuthState] = useState(defaultAuthState);
  const [selectedConfiguration, setSelectedConfiguration] = useState('authClear');

  React.useEffect(() => {
    prefetchConfiguration({
      warmAndPrefetchChrome: true,
      connectionTimeoutSeconds: 5,
      ...configs.authClear,
    });
  }, []);

  const handleAuthorize = useCallback(async provider => {
    try {
      const config = configs[provider];
      const newAuthState = await authorize({
        ...config,
        connectionTimeoutSeconds: 5,
        iosPrefersEphemeralSession: true,
      });

      const response = await fetch(`${config.issuer}/.well-known/openid-configuration`);
      const openidConfig = await response.json();
      let restApiEndpointDiscover = openidConfig.rest_api_token_endpoint

      setAuthState({
        hasLoggedInOnce: true,
        provider: provider,
        restApiEndpoint: restApiEndpointDiscover,
        ...newAuthState,
      });
    } catch (error) {
      Alert.alert('Failed to log in', error.message);
    }
  }, []);

  const handleRefresh = useCallback(async () => {
    try {
      const config = configs[authState.provider];
      const newAuthState = await refresh(config, {
        refreshToken: authState.refreshToken,
      });

      setAuthState(current => ({
        ...current,
        ...newAuthState,
        refreshToken: newAuthState.refreshToken || current.refreshToken,
      }));
    } catch (error) {
      Alert.alert('Failed to refresh token', error.message);
    }
  }, [authState]);

  const handleRevoke = useCallback(async () => {
    try {
      const config = configs[authState.provider];
      await revoke(config, {
        tokenToRevoke: authState.refreshToken,
        sendClientId: false,
        includeBasicAuth: true
      });

      setAuthState({
        provider: '',
        accessToken: '',
        accessTokenExpirationDate: '',
        refreshToken: '',
      });
    } catch (error) {
      Alert.alert('Failed to revoke token', error.message);
    }
  }, [authState]);

  const showRevoke = useMemo(() => {
    if (authState.refreshToken) {
      const config = configs[authState.provider];
      if (config.issuer || config.serviceConfiguration.revocationEndpoint) {
        return true;
      }
    }
    return false;
  }, [authState]);

  const showRestApiFunctions = useMemo(() => {
    if (authState.restApiEndpoint) {
        return true;
    }
    return false;
  }, [authState])

  const handleDataSet = useCallback(async () => {
    try {
      console.log('handleDataSet')
      console.log(authState)

      let result = await dataSet({ restApiEndpoint : authState.restApiEndpoint }, {
        accessToken: authState.accessToken,
        dataKey: "your data key there",
        dataValue: "your data value",
      });

      console.log(result.result)

    } catch (error) {
      Alert.alert('Data set failed', error.message);
    }
  }, [authState]);

  const handleDataGet = useCallback(async () => {
    console.log('handleDataGet')
    console.log(authState)

    try {
      let answer = await dataGet({ restApiEndpoint : authState.restApiEndpoint }, {
        accessToken: authState.accessToken,
        dataKey: "your data key there",
      });

      console.log(answer.dataValues)

    } catch (error) {
      Alert.alert('Failed to revoke token', error.message);
    }
  }, [authState]);

  const handleWalletsGet = useCallback(async () => {
    console.log("handleWalletsGet")
    console.log(authState.restApiEndpoint)
    console.log(authState.accessToken)
    try {
      let response = await walletsGet({ restApiEndpoint: authState.restApiEndpoint },
        { accessToken: authState.accessToken });

      console.log("[handleWalletsGet] result")
      console.log(response.result)
      console.log(response.walletsInfo)

    } catch (error) {
      Alert.alert('Failed to revoke token', error.message);
    }
  }, [authState]);

  /*
    <FormLabel>accessTokenExpirationDate</FormLabel>
    <FormValue>{authState.accessTokenExpirationDate}</FormValue>

    <FormLabel>scopes</FormLabel>
    <FormValue>{authState.scopes.join(', ')}</FormValue>
   */
  return (
    <Page>
      {authState.accessToken ? (
        <Form>
          <FormLabel>accessToken</FormLabel>
          <FormValue>{authState.accessToken}</FormValue>
          <FormLabel>refreshToken</FormLabel>
          <FormValue>{authState.refreshToken}</FormValue>
          <FormLabel>Rest API endpoint</FormLabel>
          <FormValue>{authState.restApiEndpoint}</FormValue>
        </Form>
      ) : (
        <Heading>
          {authState.hasLoggedInOnce ? 'Goodbye.' : 'Hello, stranger.'}
        </Heading>
      )}
      {!authState.accessToken ? (
        <RNPickerSelect
          items={[
            { label: 'Clear Auth',            value: 'authClear' },
            { label: 'Wallet Auth',           value: 'authWallet' },
            { label: 'Google Auth',           value: 'authIdentityProvider' },
            { label: 'Auth with transaction', value: 'authTransaction' },
            { label: 'Not guest Auth',        value: 'authGuestUpgrade' },
          ]} 
          onValueChange={(value) => setSelectedConfiguration(value)}
          value={selectedConfiguration}
        />
      ) : null}
      <ButtonContainer>
        {!authState.accessToken ? (
            <Button
              onPress={() => handleAuthorize(selectedConfiguration)}
              text="Authorize"
              color="#DA2536"
            />
        ) : null} 
        {authState.refreshToken ? (
          <Button onPress={handleRefresh} text="Refresh" color="#24C2CB" />
        ) : null}
        {showRevoke ? (
          <Button onPress={handleRevoke} text="Revoke" color="#EF525B" />
        ) : null}
        {showRestApiFunctions ? (
          <Button onPress={handleDataSet} text="Data Set" color="#EF525B" />
        ) : null}
        {showRestApiFunctions ? (
          <Button onPress={handleDataGet} text="Data Get" color="#EF525B" />
        ) : null}
        {showRestApiFunctions ? (
          <Button onPress={handleWalletsGet} text="Wallets Get" color="#EF525B" />
        ) : null}
      </ButtonContainer>
    </Page>
  );
};

export default App;
