import { fileURLToPath, URL } from "node:url";

import { defineConfig, UserConfig } from "vite";
import plugin from "@vitejs/plugin-react";
import fs from "fs";
import path from "path";
import child_process from "child_process";
const urls: string = process.env.ASPNETCORE_URLS;
const sslEnabled = urls?.indexOf("https") > -1;

const serverConfig = defineConfig({
  plugins: [plugin()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
  server: {
    proxy: {
      "^/weatherforecast": {
        target: "http://localhost:5144",
        secure: false,
      },
    },
    strictPort: true,
    port: 5173,
  },
});

if (sslEnabled) {
  console.warn(`https url found in ${urls}, attempting vite with SSL!`);
  try {
    const sslSettings = createSslSettings();
    const sslServerConfig : Partial<UserConfig> = {
      server: {
        https: sslSettings,
        proxy: {
          "^/weatherforecast": {
            target: "https://localhost:7255/",
            secure: false,
          },
        },
      },
    };
    Object.assign(serverConfig, sslServerConfig);
  } catch (ex) {
    console.error(ex);
    process.exit(-1);
  }
}

// https://vitejs.dev/config/
export default serverConfig;

/**
 * Function to create SSL settings based on the ASPNETCORE developer cert (usefull for development on a local machine)
 * @returns ssl settings
 */
function createSslSettings() {
  const baseFolder =
    process.env.APPDATA !== undefined && process.env.APPDATA !== ""
      ? `${process.env.APPDATA}/ASP.NET/https`
      : `${process.env.HOME}/.aspnet/https`;
  const pfx = "/https/react-app.pfx";

  const certificateArg = process.argv
    .map((arg) => arg.match(/--name=(?<value>.+)/i))
    .filter(Boolean)[0];
  const certificateName = certificateArg
    ? certificateArg.groups.value
    : "react-app.client";

  if (!certificateName) {
    throw new Error(
      "Invalid certificate name. Run this script in the context of an npm/yarn script or pass --name=<<app>> explicitly."
    );
  }

  const certFilePath = path.join(baseFolder, `${certificateName}.pem`);
  const keyFilePath = path.join(baseFolder, `${certificateName}.key`);

  if (!fs.existsSync(certFilePath) || !fs.existsSync(keyFilePath)) {
    if (
      0 !==
      child_process.spawnSync(
        "dotnet",
        [
          "dev-certs",
          "https",
          "--export-path",
          certFilePath,
          "--format",
          "Pem",
          "--no-password",
        ],
        { stdio: "inherit" }
      ).status
    ) {
      throw new Error("Could not create certificate.");
    }
  }

  const https = fs.existsSync(pfx)
    ? { pfx, passphrase: "password" }
    : {
        key: fs.readFileSync(keyFilePath),
        cert: fs.readFileSync(certFilePath),
      };
  return https;
}
