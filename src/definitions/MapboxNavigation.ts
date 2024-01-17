import {ILocation} from "../types/location";

export interface IMapboxNavigation {
  /**
   * Check the location permissions of the device.
   * @since 0.0.1
   */
  checkLocationPermissions(): Promise<{ value: string }>;

  /**
   * Request location permissions from the device.
   * @since 0.0.1
   */
  requestLocationPermissions(): Promise<void>;


  /**
   * Test simulated navigation
   * @since 0.0.1
   */
  simulateNavigation({routes}: { routes: Array<ILocation> }): Promise<void>;
}