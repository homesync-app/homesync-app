import React from 'react';
import { AlertTriangle, RotateCcw } from 'lucide-react';

interface ErrorBoundaryProps {
  children: React.ReactNode;
}

interface ErrorBoundaryState {
  error: Error | null;
}

/**
 * Catches render-time exceptions in any child page so a single broken screen
 * doesn't blank out the whole admin panel. Shows a recoverable fallback.
 */
export class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { error };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error('Admin panel render error:', error, info);
  }

  handleReset = () => {
    this.setState({ error: null });
  };

  render() {
    if (this.state.error) {
      return (
        <div className="min-h-[60vh] flex items-center justify-center p-6">
          <div className="state-card max-w-lg w-full">
            <div className="w-14 h-14 rounded-2xl bg-rose-500/10 flex items-center justify-center mx-auto mb-5">
              <AlertTriangle className="w-7 h-7 text-rose-400" />
            </div>
            <p className="text-lg font-bold text-rose-300">Algo se rompió en esta pantalla</p>
            <p className="text-sm text-gray-400 mt-2">
              El resto del panel sigue funcionando. Probá recargar la sección o volver a otra página.
            </p>
            <pre className="text-[11px] text-rose-400/70 bg-black/40 mt-4 p-3 rounded-xl overflow-x-auto text-left whitespace-pre-wrap break-words">
              {this.state.error.message}
            </pre>
            <button
              onClick={this.handleReset}
              className="mt-5 inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-primary text-white text-sm font-bold hover:opacity-90 transition-all"
            >
              <RotateCcw className="w-4 h-4" />
              Reintentar
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
