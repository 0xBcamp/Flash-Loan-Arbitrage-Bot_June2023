import { CombinedDarkTheme } from "src/themes/Theme";
import { StyleSheet } from "react-native";

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: CombinedDarkTheme.colors.background,
    alignItems: "center",
    justifyContent: "center",
  },
  button: {
    position: "absolute",
    bottom: 150,
  },
});
