import * as React from "react";
import { WalletContextState, WalletContextType } from "./types.wallet";
import {
  WalletConnectModal,
  useWalletConnectModal,
} from "@walletconnect/modal-react-native";
import { walletConnectProviderMetadata } from "src/constants/wallet";
import { delay } from "src/utils/time";
import { WALLETCONNECT_PROJECT_ID } from "@env";

const defaultContext: WalletContextType = {
  isConnected: false,
  address: "",
  connect(): Promise<void> {
    return new Promise(() => {});
  },
  disconnect(): Promise<void> {
    return new Promise(() => {});
  },
};

export const WalletContext =
  React.createContext<WalletContextType>(defaultContext);

type Props = {
  children?: React.ReactNode;
};

export const AuthProvider: React.FC<Props> = (props) => {
  const {
    isConnected: walletIsConnected,
    provider,
    open,
    address,
  } = useWalletConnectModal();
  const [connectContext, setConnected] = React.useState<WalletContextState>({
    isConnected: false,
    address: undefined,
  });
  const connectFnc = async () => {
    console.log("connecting to wallet...");
    try {
      await open();
      await delay(5000);
      setConnected({ isConnected: walletIsConnected, address: address });
    } catch (err) {
      console.log(err);
    }
  };
  const disconnectFnc = async () => {
    console.log(`disconnecting client: ${address}`);
    try {
      await provider?.disconnect();
      await delay(5000);
      setConnected({ isConnected: false, address: address });
    } catch (err) {
      console.log(err);
    }
  };

  React.useEffect(() => {
    const bootstrapAsync = async () => {
      console.log(`bootstrap. Wallet is connected: ${walletIsConnected}`);
      setConnected({ isConnected: walletIsConnected, address: address });
    };
    bootstrapAsync();
  }, [walletIsConnected, address]);

  return (
    <WalletContext.Provider
      value={{
        isConnected: connectContext?.isConnected,
        address: connectContext?.address,
        connect: connectFnc,
        disconnect: disconnectFnc,
      }}
    >
      <WalletConnectModal
        projectId={WALLETCONNECT_PROJECT_ID}
        providerMetadata={walletConnectProviderMetadata}
        themeMode="dark"
      />
      {props.children}
    </WalletContext.Provider>
  );
};
