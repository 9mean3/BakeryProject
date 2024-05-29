using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;

public class CanUseDeckElement : MonoBehaviour, IPointerClickHandler
{
    public DeckElement DeckInfo { get; private set; }

    [SerializeField] private TextMeshProUGUI _deckNameText;
    private DeckElement _deckInfo;

    private DeckGenerator _deckGenerator;
    private string _deckName;

    public void OnPointerClick(PointerEventData eventData)
    {
        _deckGenerator.SelectDeck = _deckInfo;
    }

    public void SetDeckInfo(DeckElement deckInfo, DeckGenerator deckGenerator)
    {
        DeckInfo = deckInfo;
        _deckGenerator = deckGenerator;

        _deckName = deckInfo.deckName;
        if(_deckName.Length > 6)
        {
            _deckName = $"{_deckName.Substring(0, 6)}.."; 
        }

        _deckNameText.text = _deckName;
        _deckInfo = deckInfo;
    }
}
