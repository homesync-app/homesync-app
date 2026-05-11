import json
import os

def update_arb(path, new_keys):
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    data.update(new_keys)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

en_keys = {
    'householdSocialHubYourRole': 'Your role: {role}',
    'householdSocialHubRoleFallback': 'Roles and rewards ready to organize the week.',
    'householdSocialHubStoreButton': 'Store',
    'householdSocialHubTrackingTitle': 'Family tracking',
    'householdSocialHubTrackingSubtitle': 'Progress by member and weekly closing.',
    'householdSocialHubShortcutMemberView': 'Member view',
    'householdSocialHubShortcutWeeklySummary': 'Weekly summary',
    'householdSocialHubRankingPoints': '{count} pts',
    'householdSocialHubRankingHidden': 'Hidden',
    'householdSocialHubRankingSurprise': 'Surprise',
    'householdSocialHubRankingLeader': '{name} is leading the week.',
    'householdSocialHubRankingHideHint': 'Since Thursday, we hide points to reveal the winner at the closing.',
    'householdSocialHubRankingEmpty': 'Complete tasks to earn points',
    'householdSocialHubRankingEmptyTab': 'No one earned points in {tab} yet',
    'householdSocialHubRankingTasksCount': '{count, plural, =1{1 task} other{{count} tasks}}',
    'householdSocialHubMemberFallback': 'Member',
    'householdSocialHubLoading': 'Loading ranking...',
    'householdSocialHubLoadError': "We couldn't load the ranking.",
    'householdSocialHubRetry': 'Retry'
}

es_keys = {
    'householdSocialHubYourRole': 'Tu rol: {role}',
    'householdSocialHubRoleFallback': 'Roles y premios listos para organizar la semana.',
    'householdSocialHubStoreButton': 'Tienda',
    'householdSocialHubTrackingTitle': 'Seguimiento familiar',
    'householdSocialHubTrackingSubtitle': 'Avances por integrante y cierre semanal.',
    'householdSocialHubShortcutMemberView': 'Vista por miembro',
    'householdSocialHubShortcutWeeklySummary': 'Resumen semanal',
    'householdSocialHubRankingPoints': '{count} pts',
    'householdSocialHubRankingHidden': 'Oculto',
    'householdSocialHubRankingSurprise': 'Sorpresa',
    'householdSocialHubRankingLeader': '{name} viene liderando la semana.',
    'householdSocialHubRankingHideHint': 'Desde el jueves guardamos los puntos para revelar al ganador al cierre.',
    'householdSocialHubRankingEmpty': 'Completen tareas para sumar puntos',
    'householdSocialHubRankingEmptyTab': 'Nadie sumó puntos en {tab} todavía',
    'householdSocialHubRankingTasksCount': '{count, plural, =1{1 tarea} other{{count} tareas}}',
    'householdSocialHubMemberFallback': 'Integrante',
    'householdSocialHubLoading': 'Cargando ranking...',
    'householdSocialHubLoadError': 'No pudimos cargar el ranking.',
    'householdSocialHubRetry': 'Reintentar'
}

update_arb('lib/l10n/app_en.arb', en_keys)
update_arb('lib/l10n/app_es.arb', es_keys)
print('ARB files updated successfully')
