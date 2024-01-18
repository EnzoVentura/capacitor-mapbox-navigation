import React from "react";
import {IonButton, IonContent, IonHeader, IonPage, IonTitle, IonToolbar} from '@ionic/react';

import {MapboxNavigation, ProfileIdentifier} from "../plugins/mapboxNavigation";

const Home: React.FC = () => {
  function launchNavigation() {
    const origin = {
      latitude: 50.66322650877968,
      longitude: 3.0496891925960754
    }

    const destination = {
      latitude: 50.63421502456915,
      longitude: 3.021310992223101
    }

    MapboxNavigation.launchNavigation({routes: [origin, destination], profile: ProfileIdentifier.AUTOMOBILE}).catch((error) => {
      console.error("launchNavigation", error)
    })
  }

  function visualizeRoute() {
    const origin = {
      latitude: 50.66322650877968,
      longitude: 3.0496891925960754
    }

    const destination = {
      latitude: 50.63421502456915,
      longitude: 3.021310992223101
    }

    MapboxNavigation.visualizeRoute({routes: [origin, destination]}).catch((error) => {
      console.error("visualizeRouteError", error)
    })
  }

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Capacitor Mapbox Navigation</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent fullscreen>
        <IonHeader collapse="condense">
          <IonToolbar>
            <IonTitle size="large">Capacitor Mapbox Navigation</IonTitle>
          </IonToolbar>
        </IonHeader>

        <IonButton onClick={() => {
          launchNavigation()
        }}>Start Navigation</IonButton>

        <IonButton onClick={() => {
          visualizeRoute()
        }}>Visualize route</IonButton>
      </IonContent>
    </IonPage>
  );
};

export default Home;
