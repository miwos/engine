// @ts-check

import { Bridge } from "@miwos/bridge";
import { NodeSerialTransport } from "@miwos/bridge/dist/NodeSerialTransport.js";
import chokidar from "chokidar";
import pico from "picocolors";
import fs from "fs/promises";
import { createColorize } from "colorize-template";
import { highlightLuaDump, highlightLuaStack } from "@miwos/highlight-lua-dump";
import { parse } from "lua-json";
import { SerialPort } from "serialport";

const ports = await SerialPort.list();
const port = ports.find(
  (port) => port.vendorId === "16C0" && port.productId === "0489"
);
if (!port) throw new Error("Miwos not connected");

const colors = {
  ...pico,
  success: pico.green,
  info: pico.gray,
  warn: pico.yellow,
  error: pico.red,
  specialKey: pico.cyan,
  key: pico.green,
  complexType: pico.magenta,
  number: pico.red,
  boolean: pico.blue,
  string: pico.yellow,
};

const colorize = createColorize(colors);

const pathToPosix = (path) => path.replace(/\\/g, "/");

const restoreCurlyBraces = (text) =>
  text.replaceAll("#<#", "{").replaceAll("#>#", "}");

const bridge = new Bridge(new NodeSerialTransport(), { debug: false });
await bridge.open({ path: port.path });

bridge.on("/data/unknown", (data) =>
  console.log(colorize`${new TextDecoder().decode(data)}`)
);

bridge.on("/log/:type", ({ args: [text] }, { type }) => {
  if (type === "dump") {
    console.log(
      highlightLuaDump(parse(`return ${text}`), (value, type) =>
        colors[type]?.(value)
      )
    );
  } else if (type === "stack") {
    const stack = parse(`return ${text}`);
    console.log(
      highlightLuaStack(stack, (value, type) => colors[type]?.(value))
    );
  } else {
    const color = colors[type] ?? pico.white;
    (console[type] ?? console.log)(restoreCurlyBraces(color(text)));
  }
});

const replaceRootDir = (path, newRoot) => {
  const parts = path.split("/");
  parts[0] = newRoot;
  return parts.join("/");
};

/** @param {string} path */
const syncFile = async (path, update = true) => {
  path = pathToPosix(path);
  const pathOnDevice = replaceRootDir(path, "lua");

  try {
    await bridge.writeFile(pathOnDevice, await fs.readFile(path, "utf8"));

    const isHotReplaced = await bridge.request("/lua/update", pathOnDevice);

    if (isHotReplaced) {
      console.log(pico.green(`hmr update ${path}`));
    } else {
      console.log(pico.green(`reload ${path}`));
    }
  } catch (error) {
    console.error(error.message);
  }
};

const watcher = chokidar.watch("src/**/*");
watcher.on("change", syncFile);

const filesToSync = [];
const handleInitialAdd = (path) => filesToSync.push(path);
watcher.on("add", handleInitialAdd);
watcher.on("ready", async () => {
  watcher.off("add", handleInitialAdd);
  for (let path of filesToSync) {
    path = pathToPosix(path);
    const pathOnDevice = replaceRootDir(path, "lua");
    try {
      await bridge.writeFile(pathOnDevice, await fs.readFile(path, "utf8"));
    } catch (error) {
      console.error(error.message);
    }
  }
});
