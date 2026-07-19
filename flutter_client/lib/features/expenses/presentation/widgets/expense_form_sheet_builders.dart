part of 'expense_form_sheet.dart';

/// Sub-builders del formulario de gastos extraídos del State para reducir el
/// tamaño de `expense_form_sheet.dart` (god file). Son `part of` la misma
/// librería, así que comparten imports y acceden a los miembros privados del
/// State sin fricción. Sólo se mueven builders que NO llaman a `setState`
/// directamente (los que sí lo hacen quedan en la clase para no disparar
/// `invalid_use_of_protected_member`).
extension _ExpenseFormBuilders on _ExpenseFormSheetState {
  Widget _buildInfoBox(String text, Color color) {
    return ExpenseInfoBox(
      text: text,
      color: color,
    );
  }

  /// Entry to the allowance ("mesada") flow - shown only when the premium
  /// Parent Mode toggle is on (family + premium + allowance_enabled). Opens the
  /// dedicated AllowanceSheet rather than reusing the expense form body
  /// (a transfer != an expense).
  Widget _buildAllowanceEntry(BuildContext context) {
    final t = AppLocalizations.of(context);
    return InkWell(
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        final sent = await AllowanceSheet.show(context);
        if (sent == true && mounted) {
          _closeSheet(true);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.payments_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.allowanceEntryTitle,
                style: AppTypography.bodyStrong.copyWith(
                  fontSize: 13.5,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ExpenseFormHeader(
      isEditing: widget.expense != null,
      isIncome: _isIncome,
      onClose: () => _closeSheet(),
      onDelete: widget.expense != null ? _confirmDelete : null,
    );
  }

  Widget _buildSectionIntro({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return ExpenseSectionIntro(
      eyebrow: eyebrow,
      title: title,
    );
  }

  Widget _buildTypeOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ExpenseTypeOption(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  Widget _buildAmountField() {
    return ExpenseAmountField(
      controller: _amountController,
      onChanged: _onAmountChanged,
      showScanAction: !_isIncome,
      isScanningReceipt: _isScanningReceipt,
      hasScanResult: _scanResult != null,
      ocrRevealTrigger: _amountRevealEpoch,
      onOcrRevealComplete: _onAmountRevealComplete,
      onScanReceipt:
          _isScanningReceipt ? null : () => _scanReceipt(ImageSource.camera),
      // Long-press: escanear un ticket ya guardado en la galería.
      onScanReceiptLongPress:
          _isScanningReceipt ? null : () => _scanReceipt(ImageSource.gallery),
      uncertainAmount: _ocrAmountUncertain,
    );
  }

  Widget _buildTitleField() {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.border.withValues(alpha: 0.82)),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          Icon(
            _isIncome
                ? Icons.account_balance_wallet_outlined
                : Icons.receipt_long_rounded,
            color: theme.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _titleController,
              style: AppTypography.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: _isIncome
                    ? t.expensesFormTitleHintIncome
                    : t.expensesFormTitleHintExpense,
                hintStyle: AppTypography.body.copyWith(
                  fontSize: 16,
                  color: theme.textMuted,
                ),
                filled: false,
                fillColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ExpenseActionTile(
      icon: icon,
      label: label,
      value: value,
      onTap: onTap,
    );
  }

  Widget _buildEqualSelection(List<MemberModel> members) {
    return ExpenseEqualSplitSelection(
      members: members,
      selectedMembers: _selectedMembersForSplit,
      onToggle: _toggleSplitMember,
    );
  }

  Widget _buildTypeToggle() {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.border.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowBase
                .withValues(alpha: theme.isDarkMode ? 0.18 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            alignment: _isIncome ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _isIncome ? AppColors.success : AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  boxShadow: [
                    BoxShadow(
                      color: (_isIncome ? AppColors.success : AppColors.primary)
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  label: t.expensesFormTypeExpense,
                  isSelected: !_isIncome,
                  onTap: _selectExpenseType,
                ),
              ),
              Expanded(
                child: _buildTypeOption(
                  label: t.expensesFormTypeIncome,
                  isSelected: _isIncome,
                  onTap: _selectIncomeType,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    return GestureDetector(
      onTap: () => showExpenseCategorySelectorSheet(
        context: context,
        categories: _currentCategories,
        selectedCategory: _selectedCategory!,
        isIncome: _isIncome,
        onSelected: _onCategorySelected,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: theme.border.withValues(alpha: 0.85)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowBase.withValues(
                alpha: theme.isDarkMode ? 0.18 : 0.02,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (_selectedCategory!['color'] as Color)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CategoryMapping.getCategoryMaterialIcon(
                  _selectedCategory!['id'],
                ),
                size: 24,
                color: _selectedCategory!['color'] as Color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.expensesFormFieldCategory,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
                    ),
                  ),
                  Text(
                    _isIncome
                        ? localizedIncomeCategoryName(
                            t,
                            _selectedCategory!['id'] as String,
                          )
                        : localizedExpenseCategoryName(
                            t,
                            _selectedCategory!['id'] as String,
                          ),
                    style: AppTypography.cardTitle.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndPayerRow(
    BuildContext context,
    MemberModel payer,
    List<MemberModel> members,
  ) {
    final caps = ref.watch(householdCapabilitiesProvider);
    final showPayer = caps.showExpensesSplit;
    final t = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.calendar_today_rounded,
            label: t.expensesFormFieldDate,
            value: DateFormat(
              'd MMM',
              Localizations.localeOf(context).toLanguageTag(),
            ).format(_selectedDate),
            onTap: _selectDate,
          ),
        ),
        if (showPayer) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionTile(
              icon: Icons.person_outline_rounded,
              label: t.expensesFormFieldPayer,
              value: payer.displayName,
              onTap: () => showExpenseMemberSelectorSheet(
                context: context,
                members: members,
                onSelected: _onPayerSelected,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton() {
    final t = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: AnimatedPress(
        scale: _isLoading ? 1 : 0.97,
        onTap: _isLoading ? null : _saveExpense,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary,
            disabledForegroundColor: Colors.white,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            shadowColor: AppColors.primary.withValues(alpha: 0.22),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: _isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : _showSuccessState
                    ? Row(
                        key: const ValueKey('success'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.expense != null
                                ? t.expensesFormSaveButtonUpdated
                                : (_isIncome
                                    ? t.expensesFormSavedIncome
                                    : t.expensesFormSavedExpense),
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('idle'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isIncome ? 'Guardar Ingreso' : 'Guardar Gasto',
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
