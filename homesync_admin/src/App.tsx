import { lazy, Suspense, useEffect, useMemo, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { supabase } from './lib/supabase';
import { SKIP_AUTH } from './lib/auth';
import { Layout } from './components/Layout';
import { ErrorBoundary } from './components/ErrorBoundary';
import { Login } from './pages/Login';
import { Loader2 } from 'lucide-react';
import type { Session } from '@supabase/supabase-js';

// Route-level code splitting keeps the initial bundle small; each page only
// loads when the admin actually navigates to it.
const Dashboard = lazy(() => import('./pages/Dashboard').then((m) => ({ default: m.Dashboard })));
const Households = lazy(() => import('./pages/Households').then((m) => ({ default: m.Households })));
const UserManagement = lazy(() =>
  import('./pages/UserManagement').then((m) => ({ default: m.UserManagement })),
);
const Activity = lazy(() => import('./pages/Activity').then((m) => ({ default: m.Activity })));
const Economy = lazy(() => import('./pages/Economy').then((m) => ({ default: m.Economy })));
const Content = lazy(() => import('./pages/Content').then((m) => ({ default: m.Content })));
const Inbox = lazy(() => import('./pages/Inbox').then((m) => ({ default: m.Inbox })));
const OcrInsights = lazy(() =>
  import('./pages/OcrInsights').then((m) => ({ default: m.OcrInsights })),
);
const ShoppingIcons = lazy(() =>
  import('./pages/ShoppingIcons').then((m) => ({ default: m.ShoppingIcons })),
);
const Settings = lazy(() => import('./pages/Settings').then((m) => ({ default: m.Settings })));

function FullScreenLoader() {
  return (
    <div className="min-h-screen bg-bg flex items-center justify-center">
      <Loader2 className="w-10 h-10 text-primary animate-spin" />
    </div>
  );
}

function ProtectedRoute({
  session,
  children,
}: {
  session: Session | null;
  children: React.ReactNode;
}) {
  if (SKIP_AUTH) return <>{children}</>;
  if (!session) return <Navigate to="/login" replace />;
  return <>{children}</>;
}

function AdminRoutes() {
  const location = useLocation();
  return (
    <Layout>
      {/* Keying on pathname resets the boundary when navigating to a new page. */}
      <ErrorBoundary key={location.pathname}>
        <Suspense fallback={<FullScreenLoader />}>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/households" element={<Households />} />
            <Route path="/users" element={<UserManagement />} />
            <Route path="/activity" element={<Activity />} />
            <Route path="/economy" element={<Economy />} />
            <Route path="/content" element={<Content />} />
            <Route path="/inbox" element={<Inbox />} />
            <Route path="/ocr-insights" element={<OcrInsights />} />
            <Route path="/shopping-icons" element={<ShoppingIcons />} />
            <Route path="/settings" element={<Settings />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Suspense>
      </ErrorBoundary>
    </Layout>
  );
}

function App() {
  const [session, setSession] = useState<Session | null | undefined>(undefined);

  const loading = useMemo(() => !SKIP_AUTH && session === undefined, [session]);

  useEffect(() => {
    if (SKIP_AUTH) return;

    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  if (loading) {
    return <FullScreenLoader />;
  }

  return (
    <Router>
      <Routes>
        {!SKIP_AUTH && <Route path="/login" element={<Login />} />}
        <Route
          path="/*"
          element={
            <ProtectedRoute session={session ?? null}>
              <AdminRoutes />
            </ProtectedRoute>
          }
        />
      </Routes>
    </Router>
  );
}

export default App;
