import React, { useState } from "react";
import { View, Text } from "react-native";
import { Button } from "react-native-paper";
import { styles } from "./HomView.styles";
import { WalletContext } from "contexts/WalletContext";
import { signerIsWhitelisted } from "services/arbitrage";
import { useWalletConnectModal } from "@walletconnect/modal-react-native";
import { ethers } from "ethers";
import { contractAddress, engineAbi } from "src/constants/contract";

type Props = {};

export const HomeView: React.FC<Props> = () => {
  const [isLoading, setIsLoading] = useState(false);
  const walletContext = React.useContext(WalletContext);
  const { provider, isConnected } = useWalletConnectModal();

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
            disabled={isLoading}
            onPress={async () => {
              setIsLoading(true);
              await walletContext.disconnect();
              setIsLoading(false);
            }}
          >
            disconnect
          </Button>
        </View>
        <View style={styles.buttonContainer}>
          <Button
            style={styles.button}
            mode="contained"
            disabled={isLoading}
            onPress={async () => {
              setIsLoading(true);
              await signerIsWhitelisted(provider);
              setIsLoading(false);
            }}
          >
            launch
          </Button>
        </View>
      </View>
    </View>
  );
};
