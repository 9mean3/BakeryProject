using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeckGenerator : MonoBehaviour
{
    [SerializeField] private RectTransform _deckElemetTrm;
    [SerializeField] private CanUseDeckElement _canUseDeckPrefab;
    [SerializeField] private SelectedDeck _selectDeckObj;

    private DeckElement _selectDeck;
    public DeckElement SelectDeck
    {
        get
        {
            return _selectDeck;
        }
        set
        {
            _selectDeck = value;
            SetSelectDeck(value);
        }
    }

    private SaveDeckData _saveDeckData = new SaveDeckData();
    private const string _saveDeckDataKey = "SaveDeckDataKey";

    public List<DeckElement> CurrentDeckList { get; private set; } = new List<DeckElement>();

    protected virtual void Start()
    {
        GenerateDeckList();
        ResetDeckList(_saveDeckData.SaveDeckList);
    }

    public void GenerateDeckList()
    {
        if (DataManager.Instance.IsHaveData(_saveDeckDataKey))
        {
            _saveDeckData = DataManager.Instance.LoadData<SaveDeckData>(_saveDeckDataKey);
        }

        foreach(DeckElement de in _saveDeckData.SaveDeckList)
        {
            CurrentDeckList.Add(de);
        }
    }

    public void ResetDeckList(List<DeckElement> deList)
    {
        foreach(Transform t in _deckElemetTrm)
        {
            Destroy(t.gameObject);
        }

        for (int i = 0; i < deList.Count; i++)
        {
            if (i % 3 == 0)
            {
                _deckElemetTrm.sizeDelta += new Vector2(0, 550);
            }

            CanUseDeckElement cude = Instantiate(_canUseDeckPrefab, _deckElemetTrm);
            cude.SetDeckInfo(deList[i], this);
            Debug.Log(cude);
        }
    }

    protected virtual void SetSelectDeck(DeckElement deckElement)
    {
        if(deckElement.deck == null)
        {
            _selectDeckObj.gameObject.SetActive(false);
            return;
        }
        print(deckElement.deck);
        _selectDeckObj.gameObject.SetActive(true);
        _selectDeckObj.SetDeckInfo(deckElement.deckName, 
                                   DeckManager.Instance.GetDeck(deckElement.deck));
    }
}
