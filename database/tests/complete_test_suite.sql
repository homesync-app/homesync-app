-- ============================================
-- HOMESYNC - COMPLETE TEST SUITE
-- ============================================
-- Ejecutar completo para verificar todo el sistema
-- ============================================

-- ============================================
-- PREPARACIÓN: Configurar usuarios de prueba
-- ============================================

-- Verificar que existen usuarios de prueba
SELECT 'SETUP: Verificando usuarios...' as step;

SELECT 
  u.id as user_id,
  u.email,
  hm.household_id,
  hm.role
FROM public.users u
LEFT JOIN public.household_members hm ON hm.user_id = u.id
ORDER BY u.email;

-- ============================================
-- TEST 1: TASKS - Crear tarea con auto-household
-- ============================================

DO $$
DECLARE
  v_task_id UUID;
  v_household_id UUID;
  v_test_user_id UUID := '5ac9da1b-11ba-4427-a994-691577ad596f'::UUID;
BEGIN
  RAISE NOTICE 'TEST 1: Crear tarea con auto-household';
  
  v_task_id := public.create_task(
    p_user_id := v_test_user_id,
    p_title := 'Test Task',
    p_category := 'cleaning',
    p_difficulty := 'easy',
    p_xp_reward := 5,
    p_coin_reward := 3
  );
  
  IF v_task_id IS NULL THEN
    RAISE EXCEPTION 'TEST 1 FAILED';
  END IF;
  
  -- Verify household was created
  SELECT household_id INTO v_household_id 
  FROM public.household_members WHERE user_id = v_test_user_id;
  
  IF v_household_id IS NULL THEN
    RAISE EXCEPTION 'TEST 1 FAILED: No household created';
  END IF;
  
  -- Cleanup
  DELETE FROM public.tasks WHERE id = v_task_id;
  
  RAISE NOTICE 'TEST 1 PASSED';
END $$;

-- ============================================
-- TEST 2: TASKS - Completar tarea y verificar balance
-- ============================================

DO $$
DECLARE
  v_task_id UUID;
  v_household_id UUID;
  v_user_id UUID := '5ac9da1b-11ba-4427-a994-691577ad596f'::UUID;
  v_balance_before INTEGER;
  v_balance_after INTEGER;
BEGIN
  RAISE NOTICE 'TEST 2: Completar tarea y verificar XP/Coins';
  
  SELECT household_id INTO v_household_id 
  FROM public.household_members WHERE user_id = v_user_id;
  
  -- Get balance before
  SELECT xp INTO v_balance_before
  FROM public.get_user_balance(v_user_id, v_household_id);
  
  -- Create and complete task
  v_task_id := public.create_task(
    p_user_id := v_user_id,
    p_title := 'Test Complete Task',
    p_xp_reward := 10,
    p_coin_reward := 5
  );
  
  PERFORM public.complete_task_transaction(
    p_request_id := 'test-' || gen_random_uuid()::TEXT,
    p_user_id := v_user_id,
    p_task_id := v_task_id,
    p_household_id := v_household_id,
    p_xp_reward := 10,
    p_coin_reward := 5,
    p_task_title := 'Test Complete Task'
  );
  
  -- Get balance after
  SELECT xp INTO v_balance_after
  FROM public.get_user_balance(v_user_id, v_household_id);
  
  IF v_balance_after < v_balance_before + 10 THEN
    RAISE EXCEPTION 'TEST 2 FAILED: XP not added correctly';
  END IF;
  
  -- Cleanup
  DELETE FROM public.ledger_entries WHERE reference_id = v_task_id;
  DELETE FROM public.tasks WHERE id = v_task_id;
  
  RAISE NOTICE 'TEST 2 PASSED';
END $$;

-- ============================================
-- TEST 3: TEMPLATES - Verificar templates cargados
-- ============================================

DO $$
DECLARE
  v_category_count INTEGER;
  v_template_count INTEGER;
BEGIN
  RAISE NOTICE 'TEST 3: Verificar task templates';
  
  SELECT COUNT(*) INTO v_category_count FROM public.categories;
  SELECT COUNT(*) INTO v_template_count FROM public.task_templates;
  
  IF v_category_count < 7 THEN
    RAISE EXCEPTION 'TEST 3 FAILED: Expected 7+ categories, got %', v_category_count;
  END IF;
  
  IF v_template_count < 47 THEN
    RAISE EXCEPTION 'TEST 3 FAILED: Expected 47+ templates, got %', v_template_count;
  END IF;
  
  RAISE NOTICE 'TEST 3 PASSED: % categories, % templates', v_category_count, v_template_count;
END $$;

-- ============================================
-- TEST 4: TEMPLATES - Clonar templates
-- ============================================

DO $$
DECLARE
  v_cloned_count INTEGER;
  v_user_id UUID := '0669d0aa-0b84-41d8-ab4c-2679e39bd969'::UUID;
  v_task_count_before INTEGER;
  v_task_count_after INTEGER;
BEGIN
  RAISE NOTICE 'TEST 4: Clonar task templates';
  
  SELECT COUNT(*) INTO v_task_count_before 
  FROM public.tasks WHERE created_by_id = v_user_id;
  
  -- Clone first 3 templates only
  v_cloned_count := public.clone_task_templates(
    p_user_id := v_user_id,
    p_template_ids := ARRAY(
      SELECT id FROM public.task_templates LIMIT 3
    )
  );
  
  IF v_cloned_count != 3 THEN
    RAISE EXCEPTION 'TEST 4 FAILED: Expected 3 cloned, got %', v_cloned_count;
  END IF;
  
  SELECT COUNT(*) INTO v_task_count_after 
  FROM public.tasks WHERE created_by_id = v_user_id;
  
  IF v_task_count_after != v_task_count_before + 3 THEN
    RAISE EXCEPTION 'TEST 4 FAILED: Tasks not created correctly';
  END IF;
  
  -- Cleanup
  DELETE FROM public.tasks WHERE created_by_id = v_user_id;
  
  RAISE NOTICE 'TEST 4 PASSED: 3 templates cloned';
END $$;

-- ============================================
-- TEST 5: EXPENSES - Crear gasto con split
-- ============================================

DO $$
DECLARE
  v_expense_id UUID;
  v_split_count INTEGER;
  v_household_id UUID;
  v_user1_id UUID := '5ac9da1b-11ba-4427-a994-691577ad596f'::UUID;
BEGIN
  RAISE NOTICE 'TEST 5: Crear gasto con split automatico';
  
  SELECT household_id INTO v_household_id 
  FROM public.household_members WHERE user_id = v_user1_id;
  
  v_expense_id := public.create_expense(
    p_user_id := v_user1_id,
    p_household_id := v_household_id,
    p_title := 'Test Gasto',
    p_amount := 100.00,
    p_paid_by := v_user1_id,
    p_category := 'groceries'
  );
  
  IF v_expense_id IS NULL THEN
    RAISE EXCEPTION 'TEST 5 FAILED: Expense not created';
  END IF;
  
  SELECT COUNT(*) INTO v_split_count 
  FROM public.expense_splits WHERE expense_id = v_expense_id;
  
  IF v_split_count < 1 THEN
    RAISE EXCEPTION 'TEST 5 FAILED: No splits created';
  END IF;
  
  -- Cleanup
  DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
  DELETE FROM public.expenses WHERE id = v_expense_id;
  
  RAISE NOTICE 'TEST 5 PASSED: Expense created with % splits', v_split_count;
END $$;

-- ============================================
-- TEST 6: EXPENSES - Balance de gastos
-- ============================================

DO $$
DECLARE
  v_household_id UUID;
  v_user1_id UUID := '5ac9da1b-11ba-4427-a994-691577ad596f'::UUID;
  v_user2_id UUID := '0669d0aa-0b84-41d8-ab4c-2679e39bd969'::UUID;
  v_expense_id UUID;
  v_user1_balance DECIMAL;
  v_user2_balance DECIMAL;
BEGIN
  RAISE NOTICE 'TEST 6: Verificar balance de gastos';
  
  SELECT household_id INTO v_household_id 
  FROM public.household_members WHERE user_id = v_user1_id;
  
  -- Create expense: user1 pays 100
  v_expense_id := public.create_expense(
    p_user_id := v_user1_id,
    p_household_id := v_household_id,
    p_title := 'Test Balance',
    p_amount := 100.00,
    p_paid_by := v_user1_id,
    p_category := 'groceries'
  );
  
  -- Check balances
  SELECT balance INTO v_user1_balance
  FROM public.get_expense_balance(v_household_id)
  WHERE get_expense_balance.user_id = v_user1_id;
  
  SELECT balance INTO v_user2_balance
  FROM public.get_expense_balance(v_household_id)
  WHERE get_expense_balance.user_id = v_user2_id;
  
  -- User1 should have positive balance, User2 negative
  IF v_user1_balance <= 0 THEN
    RAISE EXCEPTION 'TEST 6 FAILED: User1 should have positive balance, got %', v_user1_balance;
  END IF;
  
  IF v_user2_balance >= 0 THEN
    RAISE EXCEPTION 'TEST 6 FAILED: User2 should have negative balance, got %', v_user2_balance;
  END IF;
  
  -- Cleanup
  DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
  DELETE FROM public.expenses WHERE id = v_expense_id;
  
  RAISE NOTICE 'TEST 6 PASSED: User1=%, User2=%', v_user1_balance, v_user2_balance;
END $$;

-- ============================================
-- TEST 7: EXPENSES - Calcular deudas
-- ============================================

DO $$
DECLARE
  v_household_id UUID;
  v_user1_id UUID := '5ac9da1b-11ba-4427-a994-691577ad596f'::UUID;
  v_user2_id UUID := '0669d0aa-0b84-41d8-ab4c-2679e39bd969'::UUID;
  v_expense_id UUID;
  v_debt_amount DECIMAL;
  v_debt_count INTEGER;
BEGIN
  RAISE NOTICE 'TEST 7: Verificar calculo de deudas';
  
  SELECT household_id INTO v_household_id 
  FROM public.household_members WHERE user_id = v_user1_id;
  
  -- Create expense
  v_expense_id := public.create_expense(
    p_user_id := v_user1_id,
    p_household_id := v_household_id,
    p_title := 'Test Debt',
    p_amount := 100.00,
    p_paid_by := v_user1_id
  );
  
  -- Get debts
  SELECT COUNT(*), COALESCE(SUM(debt_amount), 0) INTO v_debt_count, v_debt_amount
  FROM public.get_debts(v_household_id);
  
  IF v_debt_count = 0 THEN
    RAISE EXCEPTION 'TEST 7 FAILED: No debts calculated';
  END IF;
  
  IF v_debt_amount <= 0 THEN
    RAISE EXCEPTION 'TEST 7 FAILED: Debt amount should be positive, got %', v_debt_amount;
  END IF;
  
  -- Cleanup
  DELETE FROM public.expense_splits WHERE expense_id = v_expense_id;
  DELETE FROM public.expenses WHERE id = v_expense_id;
  
  RAISE NOTICE 'TEST 7 PASSED: % debts found, total amount = %', v_debt_count, v_debt_amount;
END $$;

-- ============================================
-- TEST 8: EXPENSES - Liquidar deuda
-- ============================================

DO $$
DECLARE
  v_household_id UUID;
  v_user1_id UUID := '5ac9da1b-11ba-4427-a994-691577ad596f'::UUID;
  v_user2_id UUID := '0669d0aa-0b84-41d8-ab4c-2679e39bd969'::UUID;
  v_expense_id UUID;
  v_settlement_id UUID;
  v_user1_balance DECIMAL;
  v_user2_balance DECIMAL;
BEGIN
  RAISE NOTICE 'TEST 8: Liquidar deuda';
  
  SELECT household_id INTO v_household_id 
  FROM public.household_members WHERE user_id = v_user1_id;
  
  -- Create expense: user1 pays 100
  v_expense_id := public.create_expense(
    p_user_id := v_user1_id,
    p_household_id := v_household_id,
    p_title := 'Test Settlement',
    p_amount := 100.00,
    p_paid_by := v_user1_id
  );
  
  -- User2 settles debt
  v_settlement_id := public.settle_debt(
    p_user_id := v_user2_id,
    p_household_id := v_household_id,
    p_to_user_id := v_user1_id,
    p_amount := 50.00
  );
  
  IF v_settlement_id IS NULL THEN
    RAISE EXCEPTION 'TEST 8 FAILED: Settlement not created';
  END IF;
  
  -- Check balances are closer to 0
  SELECT balance INTO v_user1_balance
  FROM public.get_expense_balance(v_household_id)
  WHERE get_expense_balance.user_id = v_user1_id;
  
  SELECT balance INTO v_user2_balance
  FROM public.get_expense_balance(v_household_id)
  WHERE get_expense_balance.user_id = v_user2_id;
  
  -- After settlement with 50, user1 should have ~50 balance (not 50)
  IF ABS(v_user1_balance - 50.00) > 0.01 THEN
    RAISE EXCEPTION 'TEST 8 FAILED: User1 balance should be ~50, got %', v_user1_balance;
  END IF;
  
  -- Cleanup
  DELETE FROM public.expense_splits WHERE expense_id IN (v_expense_id, v_settlement_id);
  DELETE FROM public.expenses WHERE id IN (v_expense_id, v_settlement_id);
  
  RAISE NOTICE 'TEST 8 PASSED: Settlement created, balance updated';
END $$;

-- ============================================
-- TEST 9: RLS - Verificar políticas activas
-- ============================================

SELECT 'TEST 9: Verificar RLS habilitado' as test;

SELECT 
  relname as table_name,
  relrowsecurity as rls_enabled,
  (SELECT COUNT(*) FROM pg_policy WHERE pg_policy.polrelid = pg_class.oid) as policy_count
FROM pg_class
JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE pg_namespace.nspname = 'public'
AND pg_class.relkind = 'r'
AND pg_class.relname IN (
  'users', 'households', 'household_members', 'tasks', 
  'ledger_entries', 'expenses', 'expense_splits'
)
ORDER BY pg_class.relname;

-- ============================================
-- RESUMEN FINAL
-- ============================================

SELECT '========================================' as summary;
SELECT 'TEST SUITE COMPLETADO' as summary;
SELECT '9 tests ejecutados' as summary;
SELECT '========================================' as summary;
