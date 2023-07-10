export type WalletContextType = {
  isConnected: boolean;
  address: string | undefined;
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
};

export type WalletContextState = {
  isConnected: boolean;
  address: string | undefined;
};
