import { CombinedDarkTheme } from "src/themes/Theme";
import { StyleSheet } from "react-native";

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: CombinedDarkTheme.colors.background,
  },
  text: {
    color: CombinedDarkTheme.colors.notification,
  },
  button: {
    backgroundColor: CombinedDarkTheme.colors.background,
    bottom: -340,
  },
  buttonContainer: {
    alignItems: "center",
  },
});
