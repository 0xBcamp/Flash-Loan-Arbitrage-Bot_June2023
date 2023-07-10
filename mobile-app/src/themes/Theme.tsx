import {
  DarkTheme as NavigationDarkTheme,
  DefaultTheme as NavigationDefaultTheme,
} from "@react-navigation/native";
import {
  MD3DarkTheme,
  MD3LightTheme,
  adaptNavigationTheme,
} from "react-native-paper";

import merge from "deepmerge";

const customMD3DarkTheme = {
  ...MD3DarkTheme,
  animation: {
    ...MD3DarkTheme.animation,
    defaultAnimationDuration: 1000,
  },
};

const customMD3LightTheme = {
  ...MD3LightTheme,
  animation: {
    ...MD3LightTheme.animation,
    defaultAnimationDuration: 1000,
  },
};

const { LightTheme, DarkTheme } = adaptNavigationTheme({
  reactNavigationLight: NavigationDefaultTheme,
  reactNavigationDark: NavigationDarkTheme,
});

export const CombinedLightTheme = merge(customMD3LightTheme, LightTheme);
export const CombinedDarkTheme = merge(customMD3DarkTheme, DarkTheme);
