using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectDeckLoad : MonoBehaviour
{
    private const string _saveDeckKey = "PlayersDeck";

    private void Start()
    {
        if(DataManager.Instance.IsHaveData(_saveDeckKey))
        {
            List<string> deckData =
            DataManager.Instance.LoadData<PlayerSelectDeckInfoData>(_saveDeckKey).
            PlayerSelectDeck;

            MapManager.Instanace.SelectDeck = DeckManager.Instance.GetDeck(deckData);
        }
    }
}
