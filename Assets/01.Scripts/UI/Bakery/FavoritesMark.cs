using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class FavoritesMark : MonoBehaviour,IPointerClickHandler
{
    [Header("ÂüÁ¶")]
    [SerializeField] private Sprite _onFacoriteSprite;
    [SerializeField] private Sprite _notFacoriteSprite;

    private Image _visualImage;
    private bool _isThisRecipeFavorites;
    private RecipeElement _recipeElement;

    public void SetState(RecipeElement recipeElement)
    {
        _recipeElement = recipeElement;
        _visualImage = GetComponent<Image>();

        ChangeStateVisual(_recipeElement.ThisCakeData.IsFavorites);
    }

    private void ChangeStateVisual(bool isFavorites)
    {
        _isThisRecipeFavorites = isFavorites;

        _visualImage.sprite = isFavorites ? _onFacoriteSprite : _notFacoriteSprite;
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        ChangeStateVisual(!_isThisRecipeFavorites);
    }
}
