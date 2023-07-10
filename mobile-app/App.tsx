import * as React from "react";
import { Provider as PaperProvider } from "react-native-paper";
import { CombinedDarkTheme } from "./src/themes/Theme";
import { AuthProvider } from "contexts/WalletContext";
import { Navigation } from "components/Navigation";

export default function App() {
  return (
    <PaperProvider theme={CombinedDarkTheme}>
      <AuthProvider>
        <Navigation />
      </AuthProvider>
    </PaperProvider>
  );
}
