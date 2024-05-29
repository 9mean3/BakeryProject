using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetCard : MonoBehaviour
{
    private CanUseCardData _canUseCardData = new CanUseCardData();
    private const string CardDataKey = "CanUseCardsDataKey";

    public void GetCakeInfo(CardInfo cardInfo)
    {
        if(DataManager.Instance.IsHaveData(CardDataKey))
        {
            _canUseCardData = DataManager.Instance.LoadData<CanUseCardData>(CardDataKey);
        }

        if(!_canUseCardData.CanUseCardsList.Contains(cardInfo.CardName))
        {
            _canUseCardData.CanUseCardsList.Add(cardInfo.CardName);
            Debug.Log("CardAdd");
        }
        Debug.Log("CardAddComplete");
        
        DataManager.Instance.SaveData(_canUseCardData, CardDataKey);
    }
}