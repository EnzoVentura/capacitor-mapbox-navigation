import {IonButton, IonContent, IonHeader, IonPage, IonTitle, IonToolbar} from '@ionic/react';
import ExploreContainer from '../components/ExploreContainer';
import React, {useEffect} from "react";

import {MapboxNavigation} from "../plugins/mapboxNavigation";

const Home: React.FC = () => {

  function requestPerms() {
    MapboxNavigation.requestLocationPermissions().then(() => {
      console.log('requestLocationPermissions')
    })
  }

  function checkPerms() {
    MapboxNavigation.checkLocationPermissions().then((result) => {
      console.log("checkLocationPermissions", result)
      window.alert("checkLocationPermissions: " + result)
    })
  }

  function testPassString() {
    const origin = {
      latitude: 50.66322650877968,
      longitude: 3.0496891925960754
    }

    const destination = {
      latitude: 50.63421502456915,
      longitude: 3.021310992223101
    }

    MapboxNavigation.launchNavigation({routes : [origin, destination]})
  }

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>Blank</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent fullscreen>
        <IonHeader collapse="condense">
          <IonToolbar>
            <IonTitle size="large">Test</IonTitle>
          </IonToolbar>
        </IonHeader>
        <ExploreContainer/>


        <IonButton onClick={() => {
          requestPerms()
        }}>Request permissions</IonButton>

        <IonButton onClick={() => {
          checkPerms()
        }}>Check permissions</IonButton>

        <IonButton onClick={() => {
          testPassString()
        }}>Test</IonButton>
      </IonContent>
    </IonPage>
  );
};

export default Home;
