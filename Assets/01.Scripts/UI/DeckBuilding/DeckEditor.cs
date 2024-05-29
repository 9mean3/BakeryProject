using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class DeckEditor : MonoBehaviour
{
    [SerializeField] private GameObject _saveChecker;
    private DeckElement _deckElement;
    [SerializeField] private UnityEvent<CardBase> _autoSelectCardEvent;
    [SerializeField] private UnityEvent<string> _autoSetDeckNameEvent;

    private SaveDeckData _saveDeckData = new SaveDeckData();
    private const string _saveDeckDataKey = "SaveDeckDataKey";

    private void OnDisable()
    {
        if( _saveChecker.activeSelf)
        {
            if(DataManager.Instance.IsHaveData(_saveDeckDataKey))
            {
                _saveDeckData = DataManager.Instance.LoadData<SaveDeckData>(_saveDeckDataKey);
            }
            _saveDeckData.SaveDeckList.Add(_deckElement);
            DataManager.Instance.SaveData(_saveDeckData, _saveDeckDataKey);
        }
    }

    public void SetEditDeckInfo(DeckElement deckElement)
    {
        _deckElement = deckElement;

        _autoSetDeckNameEvent?.Invoke(deckElement.deckName);
        StartCoroutine(AutoSelectCardCo(DeckManager.Instance.GetDeck(deckElement.deck)));
    }

    IEnumerator AutoSelectCardCo(List<CardBase> deck)
    {
        yield return null;
        for(int i = 0; i < deck.Count; i++)
        {
            _autoSelectCardEvent?.Invoke(deck[i]);
        }
    }
}
