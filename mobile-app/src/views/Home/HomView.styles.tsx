import { CombinedDarkTheme } from "src/themes/Theme";
import { StyleSheet } from "react-native";

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: CombinedDarkTheme.colors.background,
    alignItems: "center",
    justifyContent: "center",
  },
  buttonGroupContainer: {
    flexDirection: "row",
  },
  text: {
    color: CombinedDarkTheme.colors.notification,
    fontSize: 20,
  },
  button: {},
  buttonContainer: {
    flex: 1,
  },
});
