import {ILocation} from "../types/location";

export enum ProfileIdentifier {
  AUTOMOBILE = ".automobile",
  CYCLING = ".cycling",
  WALKING = ".walking",
  AUTOMOBILE_AVOIDING_TRAFFIC = ".automobileAvoidingTraffic",
}

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
  launchNavigation({routes, profile}: { routes: Array<ILocation>, profile?: ProfileIdentifier }): Promise<void>;
}