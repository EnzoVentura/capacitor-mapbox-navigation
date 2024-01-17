import {registerPlugin} from "@capacitor/core";

import type {IMapboxNavigation} from "../definitions/MapboxNavigation";

const MapboxNavigation = registerPlugin<IMapboxNavigation>("MapboxNavigation");

export * from "../definitions/MapboxNavigation";
export {MapboxNavigation}