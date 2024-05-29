using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using TMPro;
using UnityEngine.UI;
using UnityEngine.Events;

public class ChapterElement : MonoBehaviour
{
    [SerializeField] private MapDataSO _chapterData;
    [SerializeField] private UnityEvent<MapDataSO> _loadMapActiveEvent;

    [Header("ÂüÁ¶°ª")]
    [SerializeField] private TextMeshProUGUI _chapterNameTxt;
    [SerializeField] private TextMeshProUGUI _chapterInfoTxt;
    [SerializeField] private GameObject _lockPanel;

    private void Start()
    {
        _chapterNameTxt.text = _chapterData.chapterName;
        _chapterInfoTxt.text = _chapterData.chapterInfo;
    }

    public void SelectThisChapter()
    {
        MapManager.Instanace.SelectMapData = _chapterData;
        _loadMapActiveEvent?.Invoke(_chapterData);
    }
}
