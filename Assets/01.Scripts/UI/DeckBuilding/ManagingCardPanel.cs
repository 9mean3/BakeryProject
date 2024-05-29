using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ManagingCardPanel : MonoBehaviour
{
    [SerializeField] private RectTransform _cardElementParent;
    [SerializeField] private SelectToManagingCardElement _cardElementPrefab;

    public void CreatCardElement(List<CardInfo> cardList)
    {
        for(int i = 0; i < cardList.Count; i++)
        {
            if (i % 6 == 0)
            {
                _cardElementParent.sizeDelta += new Vector2(0, 460);
            }

            SelectToManagingCardElement stmce = Instantiate(_cardElementPrefab, _cardElementParent);
            stmce.SetInfo(cardList[i]);
        }
    }
}
