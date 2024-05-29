using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class NodeLaodMap : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI _chapterNameText;
    [SerializeField] private Transform _loadMapParent;
    [SerializeField] private Transform _deckSelectParent;

    private GameObject _currentLoadMap;

    public void ActiveLoadMap(MapDataSO mapData)
    {
        MapManager.Instanace.LoadMapObject = this.gameObject;
        gameObject.SetActive(true);

        if(_currentLoadMap != null)
        {
            Destroy(_currentLoadMap);
        }

        _chapterNameText.text = mapData.chapterName;
        _currentLoadMap = Instantiate(mapData.loadMap, _loadMapParent);
    }

    public void ExitLoadMap()
    {
        gameObject.SetActive(false);
    }
}
