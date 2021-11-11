/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable require-jsdoc */
/* eslint-disable max-len */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {firestore} from "firebase-admin";

import * as Geohash from "ngeohash";
import * as randomLocation from "random-location";


admin.initializeApp();
const db = admin.firestore();

const gameDoc = "beta/game";
const playersColl = `${gameDoc}/players`;
const itemsColl = `${gameDoc}/items`;
const itemDoc = `${itemsColl}/{itemId}`;

const boundary = {
  // frimley
  // center: {latitude: -39.622476, longitude: 176.830278},
  
  // otane
  // center: {latitude: -39.895878454725036, longitude: 176.6297118718396},

  // karamu
  center: { latitude: -39.644575, longitude: 176.868368},
  radius: 50,
};

interface safetyItem {
  // eslint-disable-next-line camelcase
  item_picked_up: boolean,
  point: {
    geohash: string,
    geopoint: firestore.GeoPoint
  }

}


exports.respawnItems = functions.firestore
    .document(itemDoc)
    .onUpdate(async (change) => {
      const newValue = change.after.data();

      if (newValue.item_picked_up === true) {
        console.log("item picked up");

        const itemsNotPickedUp = await db.collection(itemsColl).where("item_picked_up", "==", false).get();

        if (itemsNotPickedUp.size === 0) {
          console.log("all items picked up! generating new items!");
          // delete old items? figure out after do user pick up item
          await generateNewItems();
        }
      }
    });


exports.generateSafetyItemsOnStartGame = functions.firestore
    .document(gameDoc)
    .onUpdate(async (change) => {
      const prevValue = change.before.data();
      const newValue = change.after.data();

      const prevGamePhase = prevValue.game_phase;
      const newGamePhase = newValue.game_phase;

      console.log(`prev: ${prevGamePhase}, new: ${newGamePhase}`);

      if (prevGamePhase == "counting" && newGamePhase == "playing") {
        console.log("changed from counting to playing, generating items!");

        await generateNewItems();
      }
    });


// Helper function
async function generateNewItems() {
  const items: safetyItem[] = [];

  //   get hiders from firestore
  const unTaggedHidersQuery = db.collection(playersColl).where("is_tagger", "==", false).where("has_been_tagged", "==", false);
  const numberOfHidersLeft: number = await unTaggedHidersQuery.get().then((querySnapshot) => {
    return querySnapshot.size;
  });

  // get 50% of remainingHiders rounded down = numberofitems
  const amountOfItems = (50 / 100) * numberOfHidersLeft;
  const amountOfItemsRoundedDown = Math.floor(amountOfItems);
  console.log(`amount of items: ${amountOfItems}, rounded down: ${amountOfItemsRoundedDown}`);


  // generate random positions for items
  for (let index = 0; index < amountOfItemsRoundedDown; index++) {
    const randomCoords = randomLocation.randomCirclePoint(boundary.center, boundary.radius);
    const newItemGeopoint = new firestore.GeoPoint(randomCoords.latitude, randomCoords.longitude);
    const hash = Geohash.encode(randomCoords.latitude, randomCoords.longitude);
    const newItem: safetyItem = {
      item_picked_up: false,
      point: {
        geopoint: newItemGeopoint,
        geohash: hash,
      },
    };

    items.push(newItem);
  }

  //put items in db
  items.forEach((newItem) => db.collection(itemsColl).add(newItem));
}


