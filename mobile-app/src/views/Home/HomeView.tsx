import React, { useState } from "react";
import { View, Text } from "react-native";
import {
  Button,
  Dialog,
  Portal,
  Appbar,
  IconButton,
  ActivityIndicator,
} from "react-native-paper";
import { styles } from "./HomView.styles";
import { WalletContext } from "contexts/WalletContext";
import { delay } from "src/utils/time";

import {
  isAccountWhitelisted,
  whitelistAccount,
  removeAccountFromWhitelist,
  launchArbitrage,
} from "services/arbitrage";
import { useWalletConnectModal } from "@walletconnect/modal-react-native";

type State = {
  isLoading: boolean;
  isWhitelisted?: boolean | undefined;
};

type DialogState = {
  isVisible: boolean;
};
type Props = {};

export const HomeView: React.FC<Props> = () => {
  const [state, setState] = useState<State>({
    isLoading: false,
    isWhitelisted: undefined,
  });
  const [dialogState, setVisible] = useState<DialogState>({
    isVisible: false,
  });

  const hideDialog = () => setVisible({ isVisible: false });

  const walletContext = React.useContext(WalletContext);
  const { provider } = useWalletConnectModal();

  React.useEffect(() => {
    const bootstrapAsync = async (provider: any) => {
      setState({ isLoading: true, isWhitelisted: undefined });
      await delay(2500);
      const isWhitelisted = await isAccountWhitelisted(provider);
      setState({ isLoading: false, isWhitelisted: isWhitelisted });
      setVisible({ isVisible: true });
    };
    bootstrapAsync(provider);
  }, [provider]);

  return (
    <View style={styles.container}>
      <Appbar.Header mode="medium">
        <Appbar.Action
          size={30}
          icon="logout"
          onPress={async () => {
            setState({
              isLoading: true,
            });
            console.log("will disconnect");
            await walletContext.disconnect();
            setState({
              isLoading: false,
            });
          }}
        />
      </Appbar.Header>
      <Portal>
        <Dialog visible={dialogState.isVisible} onDismiss={hideDialog}>
          <Dialog.Content>
            <Text
              style={styles.text}
            >{`connected account: ${walletContext.address}`}</Text>
            {state.isWhitelisted && (
              <Text style={styles.text}>{`
              Your account is whitelisted`}</Text>
            )}
            {state.isWhitelisted == false && (
              <Text style={styles.text}>{`
              Your account is not whitelisted`}</Text>
            )}
          </Dialog.Content>
          <Dialog.Actions>
            <Button
              disabled={state.isLoading}
              onPress={async () => {
                if (state.isWhitelisted == true) {
                  setState({
                    isLoading: true,
                  });
                  await removeAccountFromWhitelist(provider);
                  setState({
                    isLoading: false,
                    isWhitelisted: false,
                  });
                } else {
                  setState({
                    isLoading: true,
                  });
                  await whitelistAccount(provider);
                  setState({
                    isLoading: false,
                    isWhitelisted: true,
                  });
                }
              }}
            >
              {state.isWhitelisted
                ? "Remove from whitelist"
                : "Add to Whitelist"}
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
      <ActivityIndicator
        animating={state.isLoading}
        size={100}
      ></ActivityIndicator>
      <View style={styles.buttonContainer}>
        <IconButton
          style={styles.button}
          icon={"rocket-launch"}
          mode="contained"
          size={100}
          disabled={state.isWhitelisted == false}
          onPress={async () => {
            setState({
              isLoading: true,
            });
            await launchArbitrage(provider);
            setState({
              isLoading: false,
            });
          }}
        ></IconButton>
      </View>
    </View>
  );
};
