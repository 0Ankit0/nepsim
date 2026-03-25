import type { Metadata } from 'next';
import type { CSSProperties } from 'react';
import './globals.css';
import { Providers } from '@/components/providers';

export const metadata: Metadata = {
  title: 'NEPSIM',
  description: 'Offline-first NEPSE market simulator and learning platform',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className="antialiased"
        style={
          {
            ['--font-geist-sans' as string]: 'Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
            ['--font-geist-mono' as string]: '"SFMono-Regular", "SFMono", Consolas, "Liberation Mono", Menlo, monospace',
          } as CSSProperties
        }
      >
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
