﻿using System;
using DownKyi.Images;
using DownKyi.Models;
using DownKyi.Utils;
using Prism.Commands;
using Prism.Mvvm;
using Prism.Services.Dialogs;

namespace DownKyi.ViewModels.Dialogs;

public class BaseDialogViewModel : BindableBase, IDialogAware
{
    #region 页面属性申明

    private string? _title;

    public string? Title
    {
        get => _title;
        set => SetProperty(ref _title, value);
    }

    private VectorImage _closeIcon = null!;

    public VectorImage CloseIcon
    {
        get => _closeIcon;
        set => SetProperty(ref _closeIcon, value);
    }

    #endregion

    public BaseDialogViewModel()
    {
        #region 属性初始化

        Title = new AppInfo().Name;
        CloseIcon = new VectorImage
        {
            Height = SystemIcon.Instance().Close.Height,
            Width = SystemIcon.Instance().Close.Width,
            Data = SystemIcon.Instance().Close.Data,
            Fill = SystemIcon.Instance().Close.Fill
        };

        #endregion
    }

    #region 命令申明

    // 鼠标进入关闭按钮事件
    private DelegateCommand? _closeEnterCommand;

    public DelegateCommand CloseEnterCommand => _closeEnterCommand ??= new DelegateCommand(ExecuteCloseEnterCommand);

    /// <summary>
    /// 鼠标进入关闭按钮事件
    /// </summary>
    private void ExecuteCloseEnterCommand()
    {
        SetEnterStyle(CloseIcon);
    }

    // 鼠标离开关闭按钮事件
    private DelegateCommand? _closeLeaveCommand;

    public DelegateCommand CloseLeaveCommand => _closeLeaveCommand ??= new DelegateCommand(ExecuteCloseLeaveCommand);

    /// <summary>
    /// 鼠标离开关闭按钮事件
    /// </summary>
    private void ExecuteCloseLeaveCommand()
    {
        SetLeaveStyle(CloseIcon);
    }

    // 关闭窗口事件
    private DelegateCommand? _closeCommand;
    public DelegateCommand CloseCommand => _closeCommand ??= new DelegateCommand(ExecuteCloseCommand);

    /// <summary>
    /// 关闭窗口事件
    /// </summary>
    private void ExecuteCloseCommand()
    {
        RaiseRequestClose(new DialogResult(ButtonResult.Cancel));
    }

    #endregion

    /// <summary>
    /// 鼠标进入系统按钮时的图标样式
    /// </summary>
    /// <param name="icon">图标</param>
    private void SetEnterStyle(VectorImage icon)
    {
        icon.Fill = DictionaryResource.GetColor("ColorSystemBtnTint");
    }

    /// <summary>
    /// 鼠标离开系统按钮时的图标样式
    /// </summary>
    /// <param name="icon">图标</param>
    private void SetLeaveStyle(VectorImage icon)
    {
        icon.Fill = DictionaryResource.GetColor("ColorSystemBtnTintDark");
    }

    #region 接口实现

    //触发窗体关闭事件
    public virtual void RaiseRequestClose(IDialogResult dialogResult)
    {
        RequestClose?.Invoke(dialogResult);
    }

    public event Action<IDialogResult>? RequestClose;

    public virtual bool CanCloseDialog()
    {
        return true;
    }

    public virtual void OnDialogClosed()
    {
    }

    public virtual void OnDialogOpened(IDialogParameters parameters)
    {
    }

    #endregion
}