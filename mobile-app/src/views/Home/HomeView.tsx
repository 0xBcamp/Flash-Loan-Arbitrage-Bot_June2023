import React, { useState } from "react";
import { View, Text } from "react-native";
import { Button } from "react-native-paper";
import { styles } from "./HomView.styles";
import { WalletContext } from "contexts/WalletContext";
import { signerIsWhitelisted } from "services/arbitrage";
import { useWalletConnectModal } from "@walletconnect/modal-react-native";

type State = {
  isLoading: boolean;
  isWhitelisted: boolean | undefined;
};

type Props = {};

export const HomeView: React.FC<Props> = () => {
  const [state, setState] = useState<State>({
    isLoading: false,
    isWhitelisted: undefined,
  });
  const walletContext = React.useContext(WalletContext);
  const { provider } = useWalletConnectModal();

  return (
    <View style={styles.container}>
      <Text
        style={styles.text}
      >{`connected account: ${walletContext.address}`}</Text>
      <View style={styles.buttonGroupContainer}>
        <View style={styles.buttonContainer}>
          <Button
            style={styles.button}
            mode="contained"
            disabled={state.isLoading}
            onPress={async () => {
              setState({ isLoading: true, isWhitelisted: false });
              await walletContext.disconnect();
              setState({ isLoading: false, isWhitelisted: false });
            }}
          >
            disconnect
          </Button>
        </View>
        <View style={styles.buttonContainer}>
          <Button
            style={styles.button}
            mode="contained"
            disabled={state.isLoading}
            onPress={async () => {
              setState({ isLoading: true, isWhitelisted: false });
              const isWhitelisted = await signerIsWhitelisted(provider);
              setState({ isLoading: false, isWhitelisted: isWhitelisted });
            }}
          >
            launch
          </Button>
        </View>
      </View>
      <Text
        style={styles.text}
      >{`signer is whitelisted: ${state.isWhitelisted}`}</Text>
    </View>
  );
};
