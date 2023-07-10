import { NavigationContainer } from "@react-navigation/native";
import {
  NativeStackNavigationOptions,
  createNativeStackNavigator,
} from "@react-navigation/native-stack";
import { WalletContext } from "contexts/WalletContext";
import React from "react";
import { HomeView } from "views/Home/HomeView";
import { LoginView } from "views/Login/LoginView";

const Stack = createNativeStackNavigator();

type Props = {};

const screenOptions: NativeStackNavigationOptions = {
  animationTypeForReplace: "pop",
  presentation: "modal",
};

export const Navigation: React.FC<Props> = () => {
  const walletContext = React.useContext(WalletContext);
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
        }}
      >
        {walletContext.isConnected ? (
          <Stack.Screen
            options={screenOptions}
            name="Home"
            component={HomeView}
          />
        ) : (
          <Stack.Screen
            options={screenOptions}
            name="Login"
            component={LoginView}
          />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
};
