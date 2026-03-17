import { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { supabase } from './lib/supabase';
import { Layout } from './components/Layout';
import { Dashboard } from './pages/Dashboard';
import { TaskTemplates } from './pages/TaskTemplates';
import { Logs } from './pages/Logs';
import { UserManagement } from './pages/UserManagement';
import { Economy } from './pages/Economy';
import { Login } from './pages/Login';
import { CrashReports } from './pages/CrashReports';
import { Loader2 } from 'lucide-react';
import type { Session } from '@supabase/supabase-js';

function ProtectedRoute({
  session,
  children,
}: {
  session: Session | null;
  children: React.ReactNode;
}) {
  if (!session) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
}

function App() {
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setLoading(false);
    });

    // Listen for auth changes
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
        <Route path="/login" element={<Login />} />
        <Route
          path="/*"
          element={
            <ProtectedRoute session={session}>
              <Layout>
                <Routes>
                  <Route path="/" element={<Dashboard />} />
                  <Route path="/templates" element={<TaskTemplates />} />
                  <Route path="/logs" element={<Logs />} />
                  <Route path="/crashes" element={<CrashReports />} />
                  <Route path="/users" element={<UserManagement />} />
                  <Route path="/economy" element={<Economy />} />
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
