import { useEffect, useMemo, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { supabase } from './lib/supabase';
import { Layout } from './components/Layout';
import { Dashboard } from './pages/Dashboard';
import { Households } from './pages/Households';
import { Activity } from './pages/Activity';
import { Economy } from './pages/Economy';
import { Content } from './pages/Content';
import { Inbox } from './pages/Inbox';
import { OcrInsights } from './pages/OcrInsights';
import { Settings } from './pages/Settings';
import { Login } from './pages/Login';
import { Loader2 } from 'lucide-react';
import type { Session } from '@supabase/supabase-js';

const SKIP_AUTH = import.meta.env.VITE_SKIP_AUTH === 'true';

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
    return (
      <div className="min-h-screen bg-[#0f172a] flex items-center justify-center">
        <Loader2 className="w-10 h-10 text-primary animate-spin" />
      </div>
    );
  }

  return (
    <Router>
      <Routes>
        {!SKIP_AUTH && <Route path="/login" element={<Login />} />}
        <Route
          path="/*"
          element={
            <ProtectedRoute session={session ?? null}>
              <Layout>
                <Routes>
                  <Route path="/" element={<Dashboard />} />
                  <Route path="/households" element={<Households />} />
                  <Route path="/activity" element={<Activity />} />
                  <Route path="/economy" element={<Economy />} />
                  <Route path="/content" element={<Content />} />
                  <Route path="/inbox" element={<Inbox />} />
                  <Route path="/ocr-insights" element={<OcrInsights />} />
                  <Route path="/settings" element={<Settings />} />
                  <Route path="*" element={<Navigate to="/" replace />} />
                </Routes>
              </Layout>
            </ProtectedRoute>
          }
        />
      </Routes>
    </Router>
  );
}

export default App;
