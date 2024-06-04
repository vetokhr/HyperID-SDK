import React, {useState, useCallback, useMemo} from 'react';
import {Alert} from 'react-native';
import {
  authorize,
  refresh,
  revoke,
  prefetchConfiguration,
} from 'react-native-app-auth';
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
    auth: {
      // From https://openidconnect.net/
      issuer: 'https://login.hypersecureid.com/auth/realms/HyperID',
      clientId: 'your_client_id',
      redirectUrl: 'your.custom.scheme://localhost:4200/auth/callback',
      clientSecret: "your_client.secret",
      clientAuthMethod: "basic",
      additionalParameters: {},
      scopes: ['openid', 'email'],
   
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
};

const App = () => {
  const [authState, setAuthState] = useState(defaultAuthState);
  React.useEffect(() => {
    prefetchConfiguration({
      warmAndPrefetchChrome: true,
      connectionTimeoutSeconds: 5,
      ...configs.auth,
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

      setAuthState({
        hasLoggedInOnce: true,
        provider: provider,
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

  return (
    <Page>
      {authState.accessToken ? (
        <Form>
          <FormLabel>accessToken</FormLabel>
          <FormValue>{authState.accessToken}</FormValue>
          <FormLabel>accessTokenExpirationDate</FormLabel>
          <FormValue>{authState.accessTokenExpirationDate}</FormValue>
          <FormLabel>refreshToken</FormLabel>
          <FormValue>{authState.refreshToken}</FormValue>
          <FormLabel>scopes</FormLabel>
          <FormValue>{authState.scopes.join(', ')}</FormValue>
        </Form>
      ) : (
        <Heading>
          {authState.hasLoggedInOnce ? 'Goodbye.' : 'Hello, stranger.'}
        </Heading>
      )}

      <ButtonContainer>
        {!authState.accessToken ? (
          <>
            <Button
              onPress={() => handleAuthorize('auth')}
              text="Authorize"
              color="#DA2536"
            />
          </>
        ) : null}
        {authState.refreshToken ? (
          <Button onPress={handleRefresh} text="Refresh" color="#24C2CB" />
        ) : null}
        {showRevoke ? (
          <Button onPress={handleRevoke} text="Revoke" color="#EF525B" />
        ) : null}
      </ButtonContainer>
    </Page>
  );
};

export default App;
