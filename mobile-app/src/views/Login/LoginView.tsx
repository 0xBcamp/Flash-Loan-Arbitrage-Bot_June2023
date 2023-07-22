import React, { useState } from "react";
import { IconButton, ActivityIndicator } from "react-native-paper";
import { View } from "react-native";
import { styles } from "./LoginView.styles";
import { WalletContext } from "contexts/WalletContext";

type Props = {};

export const LoginView: React.FC<Props> = () => {
  const [isLoading, setIsLoading] = useState(false);
  const walletContext = React.useContext(WalletContext);

  return (
    <View style={styles.container}>
      <ActivityIndicator animating={isLoading} size={100}></ActivityIndicator>
      <IconButton
        mode="contained"
        icon={require("../../../assets/logo.png")}
        size={100}
        disabled={isLoading}
        style={styles.button}
        onPress={async (e) => {
          setIsLoading(true);
          await walletContext.connect();
          setIsLoading(false);
        }}
      />
    </View>
  );
};
